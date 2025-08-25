# Simple WordPress Docker Environment

A streamlined Docker environment for WordPress with automatic backup functionality.

## Features
- WordPress with MySQL setup
- Automated daily database backups
- Data persistence for WordPress files and database
- Apache logs accessible from host
- Environment variable management via .env file

## Quick Setup

1. Clone this repository
2. Copy `.env.example` to `.env` then edit `.env` to set your own passwords:
```bash
cp .env.example .env
# then edit .env to set your own passwords
```
3. Make setup script executable and run:
```bash
chmod +x setup.sh
./setup.sh
```
4. Access WordPress: http://localhost:8080

## Configuration
Edit `.env` file to customize your database settings:
```env
# Example configuration
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=exampleuser
WORDPRESS_DB_PASSWORD=examplepass
WORDPRESS_DB_NAME=exampledb
```

## Container Management
```bash
# Start containers
docker compose up -d

# Stop containers
docker compose down

# Check status
docker ps
```

## Developer Shortcuts
Use the included Makefile for common tasks:
```bash
# Build and start
make up
# Stop and remove
make down
# Validate compose file
make validate
# Tail logs of a service
make logs svc=wordpress
# Run wp-cli command
make wp cmd="plugin list"
# Trigger a backup now (requires services to be running)
make backup-now
# Restore from a backup
make restore FILE=backup/your_dump.sql.gz
```

## Backup & Restore
- Automatic daily backups are stored in `./backup` (cron-based via sidecar). Files are compressed as `*.sql.gz`.
- Schedule and retention are configurable in `.env`:
  - `BACKUP_SCHEDULE` (cron format, default daily 03:00)
  - `BACKUP_RETENTION_DAYS` (default 14 days)
- Manual backup (requires services to be running):
```bash
make backup-now
```
- Restore from dump:
```bash
gzip -dc backup/your_dump.sql.gz | docker exec -i wordpress-db sh -lc 'exec mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
```

## Troubleshooting Database Import

Having issues importing your database? Check our detailed troubleshooting guide:

### Common Issues
- MySQL 9.x authentication problems (especially on AlmaLinux)
- Database connection errors
- Permalink structure issues after import

For a complete step-by-step solution, visit our troubleshooting guide:  
[MySQL Import Troubleshooting Guide](https://macadens.com/mysql-import/)

This guide covers:
- MySQL 9.x specific solutions
- Distribution-specific issues (AlmaLinux vs Ubuntu)
- WordPress permalink fixes
- Docker permission handling

## Documentation
For detailed information:

**English**  
[https://betelgeuse.work/docker-compose-wordpress/](https://macadens.com/docker-compose-wordpress/)<br>
[https://betelgeuse.work/mysql-import/](https://macadens.com/mysql-import/)

**Japanese**  
[https://minokamo.tokyo/2024/09/19/7956/](https://minokamo.tokyo/2024/09/19/7956/)<br>
[https://minokamo.xyz/wordpress-docker/](https://minokamo.xyz/wordpress-docker/)<br>
[https://minokamo.tokyo/2024/11/21/8261/](https://minokamo.tokyo/2024/11/21/8261/)<br>
[https://minokamo.tokyo/2025/08/25/9230/](https://minokamo.tokyo/2025/08/25/9230/)

## Video Tutorials

**English**  
[https://youtu.be/Rd1NwwLfyn8](https://youtu.be/Rd1NwwLfyn8)<br>
[https://youtu.be/wQw2xxwww8c](https://youtu.be/wQw2xxwww8c)

**Japanese**  
[https://youtu.be/MjQ9jPClsaY](https://youtu.be/MjQ9jPClsaY)<br>
[https://youtu.be/eecAIxt78zE](https://youtu.be/eecAIxt78zE)
