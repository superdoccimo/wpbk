#!/bin/bash
set -e

echo "entrypoint.sh スクリプトを開始します..."

# HTMLディレクトリの権限を設定
echo "htmlディレクトリの権限を設定中..."
chown -R www-data:www-data /var/www/html || { echo "権限の設定に失敗しました"; exit 1; }
chmod -R 755 /var/www/html || { echo "権限の変更に失敗しました"; exit 1; }

# wp-config.phpが存在しない場合はWordPressファイルをコピー
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "wp-config.php が存在しません。WordPressファイルを初回のみコピーします。"
  cp -rv /usr/src/wordpress/* /var/www/html/ || { echo "ファイルのコピーに失敗しました"; exit 1; }

  # wp-config-sample.php を wp-config.php にリネーム
  if [ -f /var/www/html/wp-config-sample.php ]; then
    echo "wp-config-sample.php を wp-config.php にリネームします。"
    mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php || { echo "ファイルのリネームに失敗しました"; exit 1; }
  fi
fi

# 日本語版WordPressのダウンロードと展開
if [ ! -d /var/www/html/wp-content/languages ]; then
  echo "日本語版WordPressをダウンロードしています..."
  if ! wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip; then
    echo "ダウンロードに失敗しました"
    exit 1
  fi
  echo "日本語版WordPressを解凍しています..."
  if ! unzip /tmp/latest-ja.zip -d /tmp/wordpress-ja; then
    echo "解凍に失敗しました"
    exit 1
  fi
  
  echo "日本語版WordPressファイルをコピーしています..."
  cp -rv /tmp/wordpress-ja/wordpress/* /var/www/html/ || { echo "ファイルのコピーに失敗しました"; exit 1; }
fi

# WordPressのコアファイルを最新に更新
echo "WordPressコアファイルを更新しています..."
if ! wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip; then
  echo "WordPressコアファイルのダウンロードに失敗しました"
  exit 1
fi
if ! unzip -o /tmp/latest-ja.zip -d /tmp/wordpress-ja; then
  echo "WordPressコアファイルの解凍に失敗しました"
  exit 1
fi

# wp-contentディレクトリを除外してコアファイルを上書きコピー
rsync -a --exclude 'wp-content' /tmp/wordpress-ja/wordpress/ /var/www/html/ || { echo "WordPressコアファイルのコピーに失敗しました"; exit 1; }

# 環境変数を wp-config.php に適用
if [ -f /var/www/html/wp-config.php ]; then
  echo "環境変数を wp-config.php に適用します。"
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
fi

echo "/var/www/html の内容:"
ls -la /var/www/html

echo "entrypoint.sh スクリプトを終了します。"

exec apache2-foreground