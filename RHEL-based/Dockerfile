FROM wordpress:latest

# Use environment variables for UID and GID
ARG UID=48
ARG GID=48

# Install necessary packages
RUN apt-get update && apt-get install -y \
    mariadb-client \
    wget \
    unzip \
    rsync \
    gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create apache user and group with specified UID and GID
RUN groupadd -g ${GID} apache && \
    useradd -u ${UID} -g apache -s /sbin/nologin apache

# Create and set permissions for Apache logs
RUN mkdir -p /var/log/apache2 && \
    chown -R apache:apache /var/log/apache2 && \
    chmod -R 755 /var/log/apache2

# Set permissions for other necessary directories
RUN chown -R apache:apache /var/www/html && \
    chmod -R 755 /var/www/html

# Add ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod +x /usr/local/sbin/entrypoint.sh

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["apache2-foreground"]