# シンプルWordPress環境

## 使い方

### 1. 環境設定
```bash
cp .env.example .env
```
※ .envファイルを編集してパスワードを設定してください

### 2. インストール
```bash
chmod +x setup.sh management.sh
./setup.sh
```

### 3. 管理
```bash
./management.sh start   # 起動
./management.sh stop    # 停止
./management.sh backup  # バックアップ（要起動状態）
./management.sh status  # 状態確認
./management.sh reset   # 全リセット
```

## 備考
- バックアップは24時間ごとに自動作成
- データは `./wordpress` と `./db_data` に保存  
- バックアップは `./backup` に保存（.sql.gz形式）
- 手動バックアップにはサービス起動が必要
