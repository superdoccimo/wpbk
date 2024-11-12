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
./management.sh backup  # バックアップ
./management.sh status  # 状態確認
```

## 備考
- バックアップは24時間ごとに自動作成
- データは `./wordpress` と `./db_data` に保存
- バックアップは `./backup` に保存
