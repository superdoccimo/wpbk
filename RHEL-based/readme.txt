To launch a WordPress container on a Red Hat-based host

Modification of Dockerfile The Dockerfile has been modified to use the apache user and group, which are commonly used in Red Hat-based distributions like AlmaLinux. Environment variables are used to dynamically set the host's UID and GID.

The default UID (48) and GID (48) for Apache are used, but they can be overwritten using environment variables. The apache user and group are created with the specified UID and GID. Ownership and permissions of directories are set to the apache user and group. The container is configured to run as the apache user.

Modification of docker-compose.yml The host's UID and GID can be passed as environment variables.

Modification of entrypoint.sh It has been modified to use apache instead of www-data.

For example, if you want to use the English version, change https://ja.wordpress.org/latest-ja.zip to https://wordpress.org/latest.zip everywhere.

latest-ja.zip should also be changed to latest.zip everywhere.

There is no need to change /tmp/wordpress-ja/wordpress/, but you can change it if you prefer.

Example: For French: https://fr.wordpress.org/latest-fr_FR.zip latest-fr_FR.zip

Example(entrypoint.sh):

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
  wget https://wordpress.org/latest.zip -O /tmp/latest.zip
  echo "Extracting Japanese version of WordPress..."
  unzip /tmp/latest.zip -d /tmp/wordpress-ja
  
  echo "Copying Japanese WordPress files..."
  cp -rv /tmp/wordpress-ja/wordpress/* /var/www/html/
fi

# Update the WordPress core files to the latest version
echo "Updating WordPress core files..."
wget https://wordpress.org/latest.zip -O /tmp/latest.zip
unzip -o /tmp/latest.zip -d /tmp/wordpress-ja

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