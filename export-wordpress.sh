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
    exit 1
fi

IMAGE_NAME="$1"

# Check if containers are running
if ! docker ps | grep -q wp-site; then
    echo "Error: WordPress container is not running"
    exit 1
fi

# Login to GHCR
echo "Logging in to GitHub Container Registry..."
echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USERNAME}" --password-stdin

# Export complete WordPress file tree from the volume
echo "Exporting WordPress files..."
# Use a temporary container to tar the wp-site volume (includes themes, plugins, uploads)
docker run --rm \
    --volumes-from wp-site \
    -v "$(pwd)":/backup \
    busybox \
    sh -c "cd /var/www/html && tar czf /backup/html.tar.gz ."

# Create a new Dockerfile for the custom image, extracting the HTML content
cat > Dockerfile.export << EOF
FROM wordpress:latest
COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini
ADD html.tar.gz /var/www/html/
EOF

# Build and push the WordPress image with all file data
echo "Building WordPress image..."
docker build -t "${IMAGE_NAME}" -f Dockerfile.export .
echo "Pushing WordPress image to GHCR..."
docker push "${IMAGE_NAME}"
## Export MySQL database dump
echo "Exporting MySQL database..."
# Use root credentials to ensure required privileges for tablespace dump
docker exec "${WORDPRESS_DB_HOST}" mysqldump -uroot -p"${MYSQL_ROOT_PASSWORD}" --single-transaction --quick "${MYSQL_DATABASE}" > dump.sql

## Build MySQL initialization image with dump
repo="${IMAGE_NAME%%:*}"
tag="${IMAGE_NAME#*:}"
DB_IMAGE_NAME="${repo}-db:${tag}"

cat > Dockerfile.db << EOF
FROM mysql:lts
COPY dump.sql /docker-entrypoint-initdb.d/dump.sql
EOF

echo "Building MySQL initialization image..."
docker build -t "${DB_IMAGE_NAME}" -f Dockerfile.db .

echo "Pushing MySQL initialization image to GHCR..."
docker push "${DB_IMAGE_NAME}"

## Cleanup
rm Dockerfile.export Dockerfile.db dump.sql

echo "Export complete! WordPress image: ${IMAGE_NAME}, MySQL image: ${DB_IMAGE_NAME}"
