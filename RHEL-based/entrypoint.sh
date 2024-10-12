#!/bin/bash
set -e

echo "Starting entrypoint.sh script..."

# Ensure proper permissions for Apache logs
echo "Setting permissions for Apache logs..."
chown -R apache:apache /var/log/apache2
chmod -R 755 /var/log/apache2

# Set permissions for the HTML directory
echo "Setting permissions for the html directory..."
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

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

# Download and extract Japanese version of WordPress
if [ ! -d /var/www/html/wp-content/languages ]; then
  echo "Downloading Japanese version of WordPress..."
  wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip
  echo "Extracting Japanese version of WordPress..."
  unzip /tmp/latest-ja.zip -d /tmp/wordpress-ja
  
  echo "Copying Japanese WordPress files..."
  cp -rv /tmp/wordpress-ja/wordpress/* /var/www/html/
fi

# Update the WordPress core files to the latest version
echo "Updating WordPress core files..."
wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip
unzip -o /tmp/latest-ja.zip -d /tmp/wordpress-ja

# Copy core files while excluding the wp-content directory
rsync -a --exclude 'wp-content' /tmp/wordpress-ja/wordpress/ /var/www/html/

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

echo "Contents of /var/log/apache2:"
ls -la /var/log/apache2

echo "Switching to apache user..."
exec gosu apache "$@"