# WordPress Docker環境とバックアップ機能

このプロジェクトは、WordPress、MySQL、および自動バックアップのためのDocker環境を提供します。Dockerを使ってWordPressのセットアップと管理を簡素化し、データベースのバックアップ機能も含まれています。

## 特徴
- **DockerでのWordPressインストール**
- **永続化されたMySQLデータベース**
- **データベースの自動バックアップ機能**
- **多言語対応**: 日本語環境がデフォルトでセットアップされますが、エントリーポイントファイルでリンク先を変更することで、他の言語バージョンのWordPressにも対応可能です。たとえば、フランス語版やスペイン語版に簡単に切り替えることができます。
- **移行用のバックアップ機能**: データベースを自動バックアップし、いつでも移行や復元が可能です。
- **自動的なWordPressコアの更新**: コンテナの再起動時に、WordPressのコアファイルを自動的に最新バージョンに更新します。
- **データの永続化**: wp-content ディレクトリやデータベースがホスト側に永続化され、コンテナの再起動や更新時でもカスタマイズやコンテンツが保持されます。
- **管理しやすいログ機能**: Apacheのログをホスト側に保存する設定により、コンテナ外から簡単にアクセスしてエラーログなどを確認可能です。
- **自動バックアップのスケジューリング**: MySQLのデータベースを毎日自動バックアップし、手動操作なしで定期的にバックアップが保存されます。
- **簡単な環境変数の管理**: WordPressやMySQLの接続設定を簡単に管理でき、柔軟に環境を変更できます。

## entrypoint.sh

**目的**: コンテナ起動時に自動で実行されるスクリプトです。このスクリプトでは、WordPressの初期設定やファイルのコピー、データベース接続の設定が行われます。

## 設定の変更方法
- 初期値は日本語になっています。`entrypoint.sh` 内の以下のURLとファイル名を、お好みの言語に変更できます。

- **日本語版WordPressのダウンロードURL**
  if ! wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip; then

- このURLとファイル名を、希望の言語のWordPressダウンロードリンクに変更します。例えば、以下のような言語バージョンがあります。

  - 英語版: https://wordpress.org/latest.zip
  - フランス語版: https://fr.wordpress.org/latest-fr_FR.zip
  - ドイツ語版: https://de.wordpress.org/latest-de_DE.zip

- 変更する箇所:
  - wget のURL（例: https://ja.wordpress.org/latest-ja.zip → https://fr.wordpress.org/latest-fr_FR.zip）
  - ファイル名（例: latest-ja.zip → latest-fr_FR.zip）

## 解凍先ディレクトリについて
- 解凍先に `wordpress-ja` というディレクトリがありますが、特に変更する必要はありません。ただし、気になる場合や言語ごとにディレクトリ名を分けたい場合は、解凍先ディレクトリ（例: `wordpress-fr`）に変更することもできます。

## 具体例
- フランス語版に変更したい場合の例は、以下のようになります。

```bash
# WordPressのコアファイルを最新に更新
echo "WordPressコアファイルを更新しています..."
if ! wget https://fr.wordpress.org/latest-fr_FR.zip -O /tmp/latest-fr_FR.zip; then
  echo "WordPressコアファイルのダウンロードに失敗しました"
  exit 1
fi
if ! unzip -o /tmp/latest-fr_FR.zip -d /tmp/wordpress-fr; then
  echo "WordPressコアファイルの解凍に失敗しました"
  exit 1
fi
```
## 変更が必要なポイント
- wget のURL（例: https://ja.wordpress.org/latest-ja.zip → https://fr.wordpress.org/latest-fr_FR.zip）
- ファイル名（例: latest-ja.zip → latest-fr_FR.zip）
- 解凍先ディレクトリ（例: wordpress-ja → wordpress-fr）

## Dockerfile

**目的**: WordPress環境をカスタマイズするための基本的な設定ファイルです。

**主な設定**:
- **パーミッションの変更**: `UID` と `GID` を指定し、ホスト側とコンテナ内のファイル権限を調整しています。
- **Apacheログの永続化**: Apacheのログをホスト側に保存できるように設定しています。

詳しい設定内容については、GitHubのリポジトリ内の [Dockerfile](リンク先) を参照してください。

## .env ファイル

**目的**: 環境変数を一括管理し、WordPressとMySQLの接続設定を容易に変更できるようにします。

**主な設定内容**:
- **WORDPRESS_DB_HOST**: WordPressが接続するデータベースのホスト名。通常、`db` としてMySQLコンテナを指定します。
- **WORDPRESS_DB_USER**: データベースにアクセスするためのユーザー名。例として `exampleuser` が設定されます。
- **WORDPRESS_DB_PASSWORD**: データベースにアクセスするためのパスワード。セキュリティを考慮し、適切なパスワード（例: `examplepass`）を設定します。
- **WORDPRESS_DB_NAME**: WordPressが利用するデータベース名。例として `exampledb` が設定されています。
- **MYSQL_DATABASE**: MySQLで作成されるデータベース名。`exampledb` を指定しています。
- **MYSQL_USER**: MySQLのデータベースにアクセスするためのユーザー名。`exampleuser` を設定します。
- **MYSQL_PASSWORD**: MySQLユーザー用のパスワード。
- **MYSQL_ROOT_PASSWORD**: MySQLのルート（管理者）ユーザー用のパスワード。

**例**:
```bash
# WordPressの設定
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=exampleuser
WORDPRESS_DB_PASSWORD=examplepass
WORDPRESS_DB_NAME=exampledb

# MySQLの設定
MYSQL_DATABASE=exampledb
MYSQL_USER=exampleuser
MYSQL_PASSWORD=examplepass
MYSQL_ROOT_PASSWORD=rootpassword
```
**特徴**:
- 環境変数をファイルで一元管理できるため、設定の変更が簡単です。
- `.env` ファイルの内容は `docker-compose.yml` で参照され、環境に応じて設定を変更可能です。

## docker-compose.yml

**目的**: WordPress と MySQL の複数サービスを Docker コンテナ上で簡単に管理・運用するための設定ファイルです。`docker-compose` を使用して、複数のコンテナを一度に管理・操作することができます。

**主な設定**:
- **WordPress サービス**: WordPress のコンテナを構築し、データベース（MySQL）と連携するための設定が含まれています。環境変数やポートの指定、ファイルの永続化が行われています。
- **MySQL サービス**: WordPress が使用する MySQL データベースを提供するサービスです。データベースの設定や、永続化するためのボリューム設定が行われています。
- **バックアップ機能**: MySQL データベースの自動バックアップ機能を追加することで、データの安全性を高めています。バックアップは定期的に自動化され、外部ディレクトリに保存されます。

詳しい設定内容については、GitHubリポジトリ内の [docker-compose.yml](リンク先) を参照してください。

## php.ini

**目的**: PHP の設定ファイルであり、WordPress や他の PHP アプリケーションが動作する際の環境をカスタマイズするために使用します。このファイルでは、アップロードサイズやメモリの制限、タイムゾーンの設定などを管理します。

**主な設定**:
- **ファイルアップロードサイズの調整**: 大容量のファイルやテーマ、プラグインをアップロードできるように、`upload_max_filesize` や `post_max_size` の値を調整します。
- **メモリ使用量の制限**: PHP スクリプトが使用できる最大メモリ量を `memory_limit` で設定します。
- **タイムゾーンの設定**: `date.timezone` を使用して、サーバーが動作するタイムゾーンを適切に設定します。

**例**: 以下の設定を追加して、アップロードサイズを 200M にし、タイムゾーンを日本標準時（Asia/Tokyo）に設定します。（アメリカの場合は America/New_York など）。

```ini
upload_max_filesize = 200M
post_max_size = 200M
memory_limit = 256M
date.timezone = "Asia/Tokyo"
```
**特徴**:
- **柔軟な設定変更**: サーバーの負荷に応じて、メモリ使用量やアップロードサイズを簡単に調整できます。
- **タイムゾーン設定のサポート**: サーバーの設置場所やターゲットユーザーに合わせて、タイムゾーンを指定できます。
- **詳しい設定内容**: 詳細な設定については、GitHubリポジトリ内の [php.ini](リンク先) を参照してください。

## コンテナの立ち上げ方（ビルド込み）
**目的**: Docker Compose を使って WordPress 環境をビルドし、立ち上げる手順を説明します。
| 手順                      | コマンド                            | 説明                                                                                           |
|---------------------------|-------------------------------------|------------------------------------------------------------------------------------------------|
| Docker イメージのビルド      | `docker compose build`              | Dockerfile をもとにイメージがビルドされます。初めての実行時、または Dockerfile に変更があった場合に実行します。               |
| コンテナの起動              | `docker compose up -d`              | バックグラウンドでコンテナを起動します。                                                        |
| コンテナの状態確認          | `docker ps`                         | 現在稼働中のコンテナをリスト表示します。                                                        |
| コンテナの停止              | `docker compose down`               | コンテナを停止します。                                                                          |
| コンテナの停止とデータ削除  | `docker compose down --volumes`     | コンテナと一緒にボリュームやデータも削除します。                                                |


## データベースの手動リストアの手順

**目的**: 自動バックアップに加え、手動でデータベースをリストアする方法を提供します。トラブル発生時に `.sql` バックアップファイルを使ってデータベースを復元できます。

**主な手順**:
- **MySQLコンテナ内での操作**: `docker exec` コマンドを使って、MySQLコンテナ内にアクセスし、リストアを行います。

---

### 手順

**MySQLコンテナに接続**:  
   下記コマンドでMySQLコンテナに接続します。

   ```bash
   docker exec -it wpsql mysql -u root -p
   ```
### バックアップファイルを使ってリストア:

`.sql` ファイルを指定してデータベースをリストアします。  
例えば、`backup.sql` を使用してリストアする場合は、以下のコマンドを使用します。

   ```bash
   mysql -u root -p bkdb < /path/to/backup.sql
   ```
## 特徴

- **手動操作の簡便さ**: MySQLのリストアを手動で行う際に役立ちます。
- **トラブル時の対処**: 自動バックアップの失敗時など、緊急時に手動リストアが可能です。
# wpbk
