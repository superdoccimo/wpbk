#!/bin/bash
set -e

echo "Starting entrypoint.sh script..."

# Ensure proper permissions for Apache logs and WordPress directory
echo "Setting permissions..."
chown -R www-data:www-data /var/log/apache2 /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# If wp-config.php does not exist, copy the WordPress files
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "wp-config.php does not exist. Copying WordPress files for the first time."
  cp -rv /usr/src/wordpress/* /var/www/html/

  # Rename wp-config-sample.php to wp-config.php
  if [ -f /var/www/html/wp-config-sample.php ]; then
    echo "Renaming wp-config-sample.php to wp-config.php."
    mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  fi
fi

# Download and extract English version of WordPress
if [ ! -d /var/www/html/wp-content/languages ]; then
  echo "Downloading English version of WordPress..."
  wget https://wordpress.org/latest.zip -O /tmp/latest.zip
  echo "Extracting English version of WordPress..."
  unzip /tmp/latest.zip -d /tmp/wordpress
  
  echo "Copying English WordPress files..."
  cp -rv /tmp/wordpress/wordpress/* /var/www/html/
fi

# Update the WordPress core files to the latest version
echo "Updating WordPress core files..."
wget https://wordpress.org/latest.zip -O /tmp/latest.zip
unzip -o /tmp/latest.zip -d /tmp/wordpress

# Copy core files while excluding the wp-content directory
rsync -a --exclude 'wp-content' /tmp/wordpress/wordpress/ /var/www/html/

# Apply environment variables to wp-config.php
if [ -f /var/www/html/wp-config.php ]; then
  echo "Applying environment variables to wp-config.php."
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
  
  # Add FS_METHOD setting
  if ! grep -q "FS_METHOD" /var/www/html/wp-config.php; then
    sed -i "/<?php/a define('FS_METHOD', 'direct');" /var/www/html/wp-config.php
  fi
fi

echo "Contents of /var/www/html:"
ls -la /var/www/html

echo "Contents of /var/log/apache2:"
ls -la /var/log/apache2

# Run Apache as www-data
exec apache2-foreground