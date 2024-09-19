FROM wordpress:latest

# Set UID and GID to match the host environment
ARG UID=1000
ARG GID=1000

RUN usermod -u ${UID} www-data && groupmod -g ${GID} www-data

# Create /var/log/apache2 and set permissions
RUN mkdir -p /var/log/apache2 && chown -R www-data:www-data /var/log/apache2

# Create html directory and set ownership
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# Install necessary packages
RUN apt-get update && apt-get install -y \
    mariadb-client \
    wget \
    unzip \
    rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set entrypoint.sh
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod +x /usr/local/sbin/entrypoint.sh

# Add ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]