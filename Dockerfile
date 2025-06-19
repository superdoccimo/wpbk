FROM wordpress:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    mariadb-client \
    wget \
    unzip \
    rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set permissions for Apache logs and WordPress directory
RUN chown -R www-data:www-data /var/log/apache2 /var/www/html && \
    chmod -R 755 /var/log/apache2 /var/www/html

# Add ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod +x /usr/local/sbin/entrypoint.sh

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["apache2-foreground"]
