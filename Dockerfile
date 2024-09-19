FROM wordpress:latest

# UIDとGIDをホストの環境に合わせて設定
ARG UID=1000
ARG GID=1000

RUN usermod -u ${UID} www-data && groupmod -g ${GID} www-data

# /var/log/apache2 の作成と権限設定
RUN mkdir -p /var/log/apache2 && chown -R www-data:www-data /var/log/apache2

# htmlディレクトリの作成と所有権設定
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    mariadb-client \
    wget \
    unzip \
    rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# entrypoint.sh を設定
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod +x /usr/local/sbin/entrypoint.sh

# ServerName を追加
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]