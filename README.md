# Simple WordPress Docker Environment

A streamlined Docker environment for WordPress with automatic backup functionality.

## Features
- WordPress with MySQL setup
- Automated daily database backups
- Data persistence for WordPress files and database
- Apache logs accessible from host
- Environment variable management via .env file

## Quick Setup

1. Clone this repository
2. Make setup script executable and run:
```bash
chmod +x setup.sh
./setup.sh
```
3. Access WordPress: http://localhost:8080

## Configuration
Edit `.env` file to customize your database settings:
```env
# Example configuration
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=exampleuser
WORDPRESS_DB_PASSWORD=examplepass
WORDPRESS_DB_NAME=exampledb
```

## Container Management
```bash
# Start containers
docker compose up -d

# Stop containers
docker compose down

# Check status
docker ps
```

## Backup & Restore
- Automatic daily backups are stored in `./backup`
- Manual restore available using MySQL container

## Documentation
For detailed information:

**English**  
[https://betelgeuse.work/archives/8193](https://betelgeuse.work/archives/8193)

**Japanese**  
[https://minokamo.tokyo/2024/09/19/7956/](https://minokamo.tokyo/2024/09/19/7956/)

## Video Tutorials

**English**  
[https://youtu.be/Rd1NwwLfyn8](https://youtu.be/Rd1NwwLfyn8)

**Japanese**  
[https://youtu.be/MjQ9jPClsaY](https://youtu.be/MjQ9jPClsaY)
