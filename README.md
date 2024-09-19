# WordPress Docker Environment and Backup Function

This project provides a Docker environment for WordPress, MySQL, and automatic backups. It simplifies the setup and management of WordPress using Docker and includes a database backup feature.

## Features
- **WordPress installation with Docker**
- **Persistent MySQL database**
- **Automatic database backup function**
- **Multilingual support**: Japanese environment is set up by default, but you can switch to other language versions of WordPress by changing the link in the entry point file. For example, you can easily switch to French or Spanish versions.
- **Backup function for migration**: Automatically backs up the database, allowing migration or restoration at any time.
- **Automatic WordPress core updates**: Automatically updates WordPress core files to the latest version when the container restarts.
- **Data persistence**: The wp-content directory and database are persisted on the host side, preserving customizations and content even when containers are restarted or updated.
- **Easy-to-manage log function**: Apache logs are saved on the host side, allowing easy access to error logs from outside the container.
- **Automatic backup scheduling**: Automatically backs up the MySQL database daily, saving backups regularly without manual operation.
- **Easy management of environment variables**: WordPress and MySQL connection settings can be easily managed, allowing flexible environment changes.

## entrypoint.sh

**Purpose**: This script is automatically executed when the container starts. It performs initial WordPress setup, file copying, and database connection configuration.

## How to Change Settings
- The initial value is set to Japanese. You can change the following URL and file name in `entrypoint.sh` to your preferred language.

- **Download URL for Japanese version of WordPress**
  if ! wget https://ja.wordpress.org/latest-ja.zip -O /tmp/latest-ja.zip; then

- Change this URL and file name to the WordPress download link for your desired language. For example, there are language versions such as:

  - English version: https://wordpress.org/latest.zip
  - French version: https://fr.wordpress.org/latest-fr_FR.zip
  - German version: https://de.wordpress.org/latest-de_DE.zip

- Areas to change:
  - wget URL (e.g., https://ja.wordpress.org/latest-ja.zip → https://fr.wordpress.org/latest-fr_FR.zip)
  - File name (e.g., latest-ja.zip → latest-fr_FR.zip)

## About the Extraction Directory
- There's a directory named `wordpress-ja` as the extraction destination, but you don't need to change it specifically. However, if you prefer or want to separate directory names by language, you can change the extraction directory (e.g., `wordpress-fr`).

## Specific Example
- If you want to change to the French version, it would look like this:

```bash
# Update WordPress core files to the latest version
echo "Updating WordPress core files..."
if ! wget https://fr.wordpress.org/latest-fr_FR.zip -O /tmp/latest-fr_FR.zip; then
  echo "Failed to download WordPress core files"
  exit 1
fi
if ! unzip -o /tmp/latest-fr_FR.zip -d /tmp/wordpress-fr; then
  echo "Failed to extract WordPress core files"
  exit 1
fi
```
## Points that need to be changed
- wget URL (e.g., https://ja.wordpress.org/latest-ja.zip → https://fr.wordpress.org/latest-fr_FR.zip)
- File name (e.g., latest-ja.zip → latest-fr_FR.zip)
- Extraction directory (e.g., wordpress-ja → wordpress-fr)

## Dockerfile

**Purpose**: This is the basic configuration file for customizing the WordPress environment.

**Main settings**:
- **Permission changes**: Specifies `UID` and `GID` to adjust file permissions between the host and the container.
- **Apache log persistence**: Configures Apache logs to be saved on the host side.

For detailed configuration contents, please refer to the Dockerfile in the GitHub repository.

## .env file

**Purpose**: Manages environment variables collectively and allows easy changes to WordPress and MySQL connection settings.

**Main configuration contents**:
- **WORDPRESS_DB_HOST**: The hostname of the database WordPress connects to. Usually set to `db` to specify the MySQL container.
- **WORDPRESS_DB_USER**: The username for accessing the database. For example, `exampleuser` is set.
- **WORDPRESS_DB_PASSWORD**: The password for accessing the database. Set an appropriate password (e.g., `examplepass`) considering security.
- **WORDPRESS_DB_NAME**: The name of the database used by WordPress. For example, `exampledb` is set.
- **MYSQL_DATABASE**: The name of the database created in MySQL. Specified as `exampledb`.
- **MYSQL_USER**: The username for accessing the MySQL database. Set to `exampleuser`.
- **MYSQL_PASSWORD**: The password for the MySQL user.
- **MYSQL_ROOT_PASSWORD**: The password for the MySQL root (admin) user.

**Example**:
```bash
# WordPress settings
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=exampleuser
WORDPRESS_DB_PASSWORD=examplepass
WORDPRESS_DB_NAME=exampledb

# MySQL settings
MYSQL_DATABASE=exampledb
MYSQL_USER=exampleuser
MYSQL_PASSWORD=examplepass
MYSQL_ROOT_PASSWORD=rootpassword
```
**Features**:
- Environment variables can be managed centrally in a file, making it easy to change settings.
- The contents of the `.env` file are referenced in `docker-compose.yml`, allowing settings to be changed according to the environment.

## docker-compose.yml

**Purpose**: This is a configuration file for easily managing and operating multiple services like WordPress and MySQL on Docker containers. Using `docker-compose`, you can manage and operate multiple containers at once.

**Main settings**:
- **WordPress service**: Includes settings for building the WordPress container and coordinating with the database (MySQL). Environment variables, port specifications, and file persistence are set up.
- **MySQL service**: This service provides the MySQL database used by WordPress. It includes database configuration and volume settings for persistence.
- **Backup function**: By adding an automatic backup function for the MySQL database, it enhances data safety. Backups are automated periodically and saved to an external directory.

For detailed configuration contents, please refer to the docker-compose.yml in the GitHub repository.

## php.ini

**Purpose**: This is the PHP configuration file used to customize the environment in which WordPress or other PHP applications run. This file manages settings such as upload size, memory limits, and timezone settings.

**Main settings**:
- **Adjusting file upload size**: Adjust values for `upload_max_filesize` and `post_max_size` to allow uploading of large files, themes, or plugins.
- **Memory usage limit**: Set the maximum amount of memory that PHP scripts can use with `memory_limit`.
- **Timezone setting**: Use `date.timezone` to properly set the timezone in which the server operates.

**Example**: Add the following settings to set the upload size to 200M and set the timezone to Japan Standard Time (Asia/Tokyo). (For America, it would be America/New_York, etc.).

```ini
upload_max_filesize = 200M
post_max_size = 200M
memory_limit = 256M
date.timezone = "Asia/Tokyo"
```
**Features**:
- **Flexible configuration changes**: Memory usage and upload size can be easily adjusted according to server load.
- **Timezone setting support**: The timezone can be specified to match the server location or target users.
- **Detailed configuration content**: For detailed settings, please refer to php.ini in the GitHub repository.

## How to Launch Containers (Including Build)
**Purpose**: Explains the procedure for building and launching a WordPress environment using Docker Compose.
| Step                      | Command                             | Description                                                                                    |
|---------------------------|-------------------------------------|------------------------------------------------------------------------------------------------|
| Build Docker images       | `docker compose build`              | Builds images based on the Dockerfile. Run this for the first time or when Dockerfile changes. |
| Start containers          | `docker compose up -d`              | Starts containers in the background.                                                            |
| Check container status    | `docker ps`                         | Lists currently running containers.                                                             |
| Stop containers           | `docker compose down`               | Stops the containers.                                                                           |
| Stop and delete data      | `docker compose down --volumes`     | Stops containers and deletes volumes and data.                                                  |


## Manual Database Restore Procedure

**Purpose**: Provides a method for manually restoring the database in addition to automatic backups. Allows database restoration using `.sql` backup files in case of trouble.

**Main Steps**:
- **Operations inside MySQL container**: Use the `docker exec` command to access the MySQL container and perform the restore.

---

### Procedure

**Connect to MySQL container**:  
   Connect to the MySQL container using the following command:

   ```bash
   docker exec -it wpsql mysql -u root -p
   ```
### Restore using backup file:

Restore the database using a specified `.sql` file.  
For example, to restore using `backup.sql`, use the following command:

   ```bash
   mysql -u root -p bkdb < /path/to/backup.sql
   ```
## Features

- **Ease of manual operation**: Useful when performing MySQL restores manually.
- **Troubleshooting**: Allows manual restore in emergencies, such as when automatic backups fail.

## Detailed Explanation

**English**  
[https://betelgeuse.work/archives/8193](https://betelgeuse.work/archives/8193)

**Japanese**  
[https://minokamo.tokyo/2024/09/19/7956/](https://minokamo.tokyo/2024/09/19/7956/)

## Videos

**English**  
[https://youtu.be/Rd1NwwLfyn8](https://youtu.be/Rd1NwwLfyn8)

**Japanese**  
[https://youtu.be/MjQ9jPClsaY](https://youtu.be/MjQ9jPClsaY)
