#!/usr/bin/env bash
set -euo pipefail

MYSQL_HOST="${MYSQL_HOST:-db}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"
BACKUP_DIR="/backup"
BACKUP_GZIP_LEVEL="${BACKUP_GZIP_LEVEL:-1}"
# Comma-separated table names to ignore (e.g., wp_actionscheduler_actions,wp_actionscheduler_logs)
BACKUP_IGNORE_TABLES="${BACKUP_IGNORE_TABLES:-}"

# Tuning knobs
SKIP_WP_TABLE_WAIT="${BACKUP_SKIP_WP_WAIT:-false}"
WP_WAIT_MAX_TRIES="${BACKUP_WP_WAIT_MAX_TRIES:-40}"
WP_WAIT_SLEEP_SEC="${BACKUP_WP_WAIT_SLEEP_SEC:-5}"
FAIL_IF_NO_WP_TABLES="${BACKUP_FAIL_IF_NO_WP_TABLES:-false}"

log() {
  echo "[backup] $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

wait_for_db() {
  local tries=0
  local max_tries=30
  while ! mysqladmin ping -h "$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent >/dev/null 2>&1; do
    tries=$((tries+1))
    if [ "$tries" -ge "$max_tries" ]; then
      log "DB not reachable after $max_tries attempts"; return 1
    fi
    log "Waiting for database... ($tries/$max_tries)"
    sleep 5
  done
  log "Database connection established"
}

ensure_wp_tables() {
  # Wait until a typical WP table appears
  local tries=0
  local max_tries=$WP_WAIT_MAX_TRIES
  local sleep_sec=$WP_WAIT_SLEEP_SEC
  while ! mysql -h "$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SHOW TABLES;" 2>/dev/null | grep -q "wp_options"; do
    tries=$((tries+1))
    if [ "$tries" -ge "$max_tries" ]; then
      log "WordPress tables not found after $max_tries attempts"; return 1
    fi
    log "Waiting for WordPress tables... ($tries/$max_tries)"
    sleep "$sleep_sec"
  done
  log "WordPress tables detected"
}

perform_backup() {
  mkdir -p "$BACKUP_DIR"
  local ts
  ts=$(date +%Y%m%d_%H%M%S)
  local outfile="$BACKUP_DIR/${MYSQL_DATABASE}_backup_${ts}.sql.gz"
  log "Starting backup to $outfile"
  # Build ignore-table args if provided
  local IGNORE_ARGS=()
  if [ -n "$BACKUP_IGNORE_TABLES" ]; then
    IFS=',' read -r -a _IGN_ARR <<< "$BACKUP_IGNORE_TABLES"
    for t in "${_IGN_ARR[@]}"; do
      t_trimmed=$(echo "$t" | xargs)
      [ -n "$t_trimmed" ] && IGNORE_ARGS+=("--ignore-table=${MYSQL_DATABASE}.${t_trimmed}")
    done
  fi
  if mysqldump \
      -h "$MYSQL_HOST" \
      -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" \
      --single-transaction --quick --no-tablespaces --set-gtid-purged=OFF \
      "${IGNORE_ARGS[@]}" \
      "$MYSQL_DATABASE" | gzip -${BACKUP_GZIP_LEVEL} -c > "$outfile"; then
    log "Backup completed: $(ls -lh "$outfile" | awk '{print $5, $9}')"
  else
    log "Backup failed"; return 1
  fi
}

prune_backups() {
  if [ -n "$RETENTION_DAYS" ] && [ "$RETENTION_DAYS" -gt 0 ] 2>/dev/null; then
    log "Pruning backups older than $RETENTION_DAYS days"
    find "$BACKUP_DIR" -type f -name "${MYSQL_DATABASE}_backup_*.sql.gz" -mtime +"$RETENTION_DAYS" -print -delete || true
  fi
}

main() {
  wait_for_db || exit 1
  if [ "$SKIP_WP_TABLE_WAIT" = "true" ] || [ "$SKIP_WP_TABLE_WAIT" = "1" ]; then
    log "Skipping WordPress tables wait as requested"
  else
    if ! ensure_wp_tables; then
      if [ "$FAIL_IF_NO_WP_TABLES" = "true" ] || [ "$FAIL_IF_NO_WP_TABLES" = "1" ]; then
        log "Exiting because WordPress tables were not found and FAIL_IF_NO_WP_TABLES is set"; exit 1
      else
        log "Continuing without WordPress tables (dump may be empty)"
      fi
    fi
  fi
  perform_backup || exit 1
  prune_backups || true
}

main "$@"
