#!/bin/bash
set -e

echo "Starting entrypoint.sh script..."

# Set permissions for the HTML directory
echo "Setting permissions for the html directory..."
chown -R www-data:www-data /var/www/html || { echo "Failed to set permissions"; exit 1; }
chmod -R 755 /var/www/html || { echo "Failed to change permissions"; exit 1; }

# If wp-config.php does not exist, copy the WordPress files
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "wp-config.php does not exist. Copying WordPress files for the first time."
  cp -rv /usr/src/wordpress/* /var/www/html/ || { echo "Failed to copy files"; exit 1; }

  # Rename wp-config-sample.php to wp-config.php
  if [ -f /var/www/html/wp-config-sample.php ]; then
    echo "Renaming wp-config-sample.php to wp-config.php."
    mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php || { echo "Failed to rename file"; exit 1; }
  fi
fi

# Download and extract Japanese version of WordPress
if [ ! -d /var/www/html/wp-content/languages ]; then
  echo "Downloading Japanese version of WordPress..."
  if ! wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip; then
    echo "Failed to download"
    exit 1
  fi
  echo "Extracting Japanese version of WordPress..."
  if ! unzip /tmp/latest-ja.zip -d /tmp/wordpress-ja; then
    echo "Failed to extract"
    exit 1
  fi
  
  echo "Copying Japanese WordPress files..."
  cp -rv /tmp/wordpress-ja/wordpress/* /var/www/html/ || { echo "Failed to copy files"; exit 1; }
fi

# Update the WordPress core files to the latest version
echo "Updating WordPress core files..."
if ! wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip; then
  echo "Failed to download WordPress core files"
  exit 1
fi
if ! unzip -o /tmp/latest-ja.zip -d /tmp/wordpress-ja; then
  echo "Failed to extract WordPress core files"
  exit 1
fi

# Copy core files while excluding the wp-content directory
rsync -a --exclude 'wp-content' /tmp/wordpress-ja/wordpress/ /var/www/html/ || { echo "Failed to copy WordPress core files"; exit 1; }

# Apply environment variables to wp-config.php
if [ -f /var/www/html/wp-config.php ]; then
  echo "Applying environment variables to wp-config.php."
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
fi

echo "Contents of /var/www/html:"
ls -la /var/www/html

echo "Exiting entrypoint.sh script."

exec apache2-foreground