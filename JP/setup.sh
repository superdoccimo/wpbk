#!/bin/bash

# エラーハンドリング
set -e

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}WordPressセットアップを開始します${NC}"

# 必要なディレクトリの作成
for dir in wordpress db_data backup logs/apache2; do
    if [ ! -d "./$dir" ]; then
        echo "ディレクトリを作成: $dir"
        mkdir -p "./$dir"
    fi
done

# 権限の設定
echo "権限を設定しています..."
sudo chown -R 33:33 ./wordpress
sudo chmod 777 ./backup
sudo find ./wordpress -type d -exec chmod 755 {} \;
sudo find ./wordpress -type f -exec chmod 644 {} \;

# Dockerの確認
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Dockerがインストールされていません${NC}"
    echo "インストール方法: https://docs.docker.com/engine/install/"
    exit 1
fi

# コンテナのビルドと起動
echo "Dockerコンテナを起動しています..."
docker compose up -d --build

# 起動確認
echo "コンテナの起動を確認しています..."
attempt=0
max_attempts=30

while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:8080 > /dev/null; then
        echo -e "${GREEN}セットアップが完了しました！${NC}"
        echo -e "WordPressは以下のURLでアクセスできます:"
        echo -e "${GREEN}http://localhost:8080${NC}"
        echo -e "\n管理画面の初期設定を行ってください"
        echo "バックアップは24時間ごとに自動的に作成されます"
        echo -e "\n補足コマンド:"
        echo "./management.sh start  - 起動"
        echo "./management.sh stop   - 停止"
        echo "./management.sh status - 状態確認"
        exit 0
    fi
    
    echo "起動待機中... ($((attempt + 1))/$max_attempts)"
    sleep 5
    attempt=$((attempt + 1))
done

echo -e "${YELLOW}警告: タイムアウトしました。ログを確認してください:${NC}"
echo "docker logs wordpress"
