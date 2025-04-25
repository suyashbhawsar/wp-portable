# Automated WordPress Docker Environment with GHCR Integration

This project provides a set of automated tools to easily set up, customize, export, and redeploy WordPress environments using Docker and GitHub Container Registry (GHCR).

## 🚀 Features

- One-command WordPress initialization with Docker
- GHCR integration for storing and pulling custom WordPress images
- Export complete WordPress environments (themes, plugins, content, database) via companion MySQL init image
- Easy import functionality to clone WordPress sites anywhere
- Customizable database environment via variables
- Production-ready PHP configuration
- Secure local-only port binding by default

## 📋 Prerequisites

- Docker installed and running
- GitHub account with GHCR access
- GitHub Personal Access Token with `write:packages` permission
- Bash shell environment

## 🛠️ Setup

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd wp-portable
   ```

2. Copy the example environment file and configure your settings:
   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your database and GHCR credentials.

## 📖 Usage

### Initialize WordPress

To start a new WordPress instance:
```bash
./init-wordpress.sh
```
Access WordPress at http://127.0.0.1:8000

### Export WordPress and Database

To export your customized WordPress and its database as Docker images and push to GHCR:
```bash
./export-wordpress.sh ghcr.io/<username>/wordpress-custom:tag
```

This will:
- Push the WordPress image: `ghcr.io/<username>/wordpress-custom:tag`
- Push the MySQL initialization image: `ghcr.io/<username>/wordpress-custom-db:tag`

### Import WordPress and Database

To import and run a WordPress site with its database from GHCR:
```bash
./import-wordpress.sh ghcr.io/<username>/wordpress-custom:tag
```

This will:
- Pull and run the MySQL initialization image to restore your database
- Pull and run the WordPress image to serve your site

## ⚙️ Environment Variables

### WordPress Configuration
- `WORDPRESS_DB_HOST` - MySQL container name (host) for WordPress and export/import scripts
- `WORDPRESS_DB_USER` - Database user
- `WORDPRESS_DB_PASSWORD` - Database password
- `WORDPRESS_DB_NAME` - Database name

### MySQL Configuration
- `MYSQL_DATABASE` - Database name
- `MYSQL_USER` - Database user
- `MYSQL_PASSWORD` - Database password
- `MYSQL_ROOT_PASSWORD` - Root password

## 🔧 PHP Configuration

The default PHP configuration includes:
- Maximum upload file size: 512M
- Memory limit: 512M
- Max execution time: 1200 seconds
- Max input time: 600 seconds

## 🔒 Security

- Default port binding is to localhost only (127.0.0.1:8000)
- Environment variables for sensitive data
- GHCR authentication required for image push/pull

## 🤝 Contributing

Feel free to submit issues and enhancement requests.
