SHELL := /bin/bash

.PHONY: up down build ps logs validate wp backup-now restore perms-fix clean

up:
	docker compose up -d --build

down:
	docker compose down

build:
	docker compose build

ps:
	docker compose ps

logs:
	@[ -n "$(svc)" ] || (echo "Usage: make logs svc=wordpress" && exit 1)
	docker compose logs -f $(svc)

validate:
	docker compose config -q

# Example: make wp cmd="plugin list"
wp:
	@[ -n "$(cmd)" ] || (echo "Usage: make wp cmd='...wp arguments...'" && exit 1)
	docker compose run --rm wpcli wp $(cmd)

backup-now:
	docker compose exec wpsql /usr/local/bin/backup.sh

# Start backup inside running wpsql container and return immediately
backup-now-detached:
	@docker compose ps --format json >/dev/null 2>&1 || (echo "Please start services: make up" && exit 1)
	docker compose exec -d wpsql sh -lc '/usr/local/bin/backup.sh'

# Tail backup service logs
backup-logs:
	docker compose logs -f wpsql

# Example: make restore FILE=backup/your_dump.sql.gz
restore:
	@[ -n "$(FILE)" ] || (echo "Usage: make restore FILE=backup/your_dump.sql.gz" && exit 1)
	gzip -dc $(FILE) | docker exec -i wordpress-db sh -lc 'exec mysql -u "$$MYSQL_USER" -p"$$MYSQL_PASSWORD" "$$MYSQL_DATABASE"'

perms-fix:
	sudo chown -R 33:33 ./wordpress/wp-content
	sudo find ./wordpress/wp-content -type d -exec chmod 755 {} \;
	sudo find ./wordpress/wp-content -type f -exec chmod 644 {} \;

clean:
	rm -rf db_data wordpress logs/apache2 backup
