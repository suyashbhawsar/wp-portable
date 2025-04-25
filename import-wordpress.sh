#!/bin/bash

# Exit on error
set -e

# Check if image name is provided
if [ -z "$1" ]; then
    echo "Error: Please provide an image name"
    echo "Usage: $0 ghcr.io/<username>/wordpress-custom:tag"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    echo "Please copy .env.example to .env and configure your settings"
    exit 1
fi

IMAGE_NAME="$1"

# Login to GHCR
echo "Logging in to GitHub Container Registry..."
echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USERNAME}" --password-stdin

# Derive MySQL image name from WordPress image name
repo="${IMAGE_NAME%%:*}"
tag="${IMAGE_NAME#*:}"
DB_IMAGE_NAME="${repo}-db:${tag}"

# Pull MySQL initialization image
echo "Pulling MySQL initialization image..."
docker pull "${DB_IMAGE_NAME}"

# Create docker network if it doesn't exist
docker network inspect wordpress-net >/dev/null 2>&1 || docker network create wordpress-net

echo "Starting MySQL container..."
docker run -d \
    --name "${WORDPRESS_DB_HOST}" \
    --network wordpress-net \
    -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
    -e MYSQL_USER="${MYSQL_USER}" \
    -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
    -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
    "${DB_IMAGE_NAME}"

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
sleep 20

# Pull and start the custom WordPress image
echo "Pulling custom WordPress image..."
docker pull "${IMAGE_NAME}"

echo "Starting WordPress container..."
docker run -d \
    --name wp-site \
    --network wordpress-net \
    -p "${WP_PORT:-127.0.0.1:8000}:80" \
    -e WORDPRESS_DB_HOST="${WORDPRESS_DB_HOST}" \
    -e WORDPRESS_DB_USER="${WORDPRESS_DB_USER}" \
    -e WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD}" \
    -e WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME}" \
    "${IMAGE_NAME}"

echo "WordPress import complete!"
echo "Access your site at http://${WP_PORT:-127.0.0.1:8000}"
echo "Please wait a few moments for WordPress to fully initialize..." 