#!/bin/bash
set -e

# Check required environment variables
if [ -z "$DOCKER_USER" ] || [ -z "$DOCKER_PWD" ]; then
    echo "ERROR: DOCKER_USER and DOCKER_PWD environment variables are required"
    exit 1
fi

# Check command line arguments
if [ $# -lt 2 ]; then
    echo "Usage: docker run ... builder <github_repo> <dockerhub_repo> [project_dir]"
    echo "Example: docker run ... builder mluukkai/express_app ark2023/testing"
    exit 1
fi

# Login to Docker Hub non-interactively
echo "Logging in to Docker Hub as $DOCKER_USER..."
echo "$DOCKER_PWD" | docker login -u "$DOCKER_USER" --password-stdin

if [ $? -ne 0 ]; then
    echo "ERROR: Docker Hub login failed"
    exit 1
fi

# Run the builder script with provided arguments
exec /app/builder.sh "$@"