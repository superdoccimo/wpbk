#!/bin/bash

# Create necessary directories if they don't exist
mkdir -p ./wordpress/wp-content
mkdir -p ./backup
mkdir -p ./logs/apache2

# Change the owner and group of the WordPress content directory
sudo chown -R 33:33 ./wordpress/wp-content

# Set permissions for directories and files within the WordPress content directory
sudo find ./wordpress/wp-content -type d -exec chmod 755 {} \;
sudo find ./wordpress/wp-content -type f -exec chmod 644 {} \;

# Set permissions for backup directory
sudo chmod 777 ./backup

# Build and start the Docker containers
docker compose up -d --build

# Wait until the container is fully up and running
echo "Checking if the container is up..."
until [ "`docker inspect -f {{.State.Health.Status}} wordpress`" == "healthy" ]; do
  sleep 5
done

# Change the ownership again
sudo chown -R 33:33 ./wordpress/wp-content

echo "Ownership has been updated."

echo "Setup is complete. You can access WordPress at http://localhost:8080."
