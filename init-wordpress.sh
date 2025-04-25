#!/bin/bash

# Exit on error
set -e

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    echo "Please copy .env.example to .env and configure your settings"
    exit 1
fi

# Create docker network if it doesn't exist
docker network inspect wordpress-net >/dev/null 2>&1 || docker network create wordpress-net

# Start MySQL container
echo "Starting MySQL container..."
docker run -d \
    --name "${WORDPRESS_DB_HOST}" \
    --network wordpress-net \
    -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
    -e MYSQL_USER="${MYSQL_USER}" \
    -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
    -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
    mysql:lts

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
sleep 20

# Start WordPress container
echo "Starting WordPress container..."
docker run -d \
    --name wp-site \
    --network wordpress-net \
    -p "${WP_PORT:-127.0.0.1:8000}:80" \
    -v "$(pwd)/uploads.ini:/usr/local/etc/php/conf.d/uploads.ini" \
    -e WORDPRESS_DB_HOST="${WORDPRESS_DB_HOST}" \
    -e WORDPRESS_DB_USER="${WORDPRESS_DB_USER}" \
    -e WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD}" \
    -e WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME}" \
    wordpress:latest

echo "WordPress setup complete!"
echo "Access your site at http://${WP_PORT:-127.0.0.1:8000}"
echo "Please wait a few moments for WordPress to fully initialize..." 
