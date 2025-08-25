#!/bin/bash

case "$1" in
    "start")
        docker compose up -d
        echo "WordPressを起動しました - http://localhost:8080"
        ;;
    "stop")
        docker compose down
        echo "WordPressを停止しました"
        ;;
    "backup")
        echo "バックアップを開始します..."
        cd ..
        make backup-now
        echo "バックアップが完了しました。./backup フォルダを確認してください。"
        ;;
    "status")
        docker compose ps
        echo "\nWordPressコンテナのログ:"
        docker logs --tail 20 wordpress
        ;;
    "reset")
        read -p "全てのデータを削除します。よろしいですか？ (y/n) " answer
        if [ "$answer" = "y" ]; then
            docker compose down -v
            sudo rm -rf wordpress/* db_data/* backup/*
            echo "リセット完了しました。./setup.sh で再セットアップできます"
        fi
        ;;
    *)
        echo "使用方法:"
        echo "  ./management.sh start   - WordPressを起動"
        echo "  ./management.sh stop    - WordPressを停止"
        echo "  ./management.sh backup  - 手動バックアップを作成"
        echo "  ./management.sh status  - 状態を確認"
        echo "  ./management.sh reset   - 全てリセット"
        ;;
esac
