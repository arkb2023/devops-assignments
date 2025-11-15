#!/bin/bash
# The script will clone the repo to a temporary directory, build the Docker image, and push it to Docker Hub with appropriate tags.
# Docker Builder Script
# Usage: ./builder.sh <github_repo> <dockerhub_repo> [project_dir]
# Example: ./builder.sh username/express_app dockeruser/testing
# Example with project dir: ./builder.sh username/monorepo dockeruser/app backend

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to show usage
usage() {
    echo "Usage: $0 <github_repo> <dockerhub_repo> [project_dir]"
    echo ""
    echo "Arguments:"
    echo "  github_repo      GitHub repository in format: owner/repo"
    echo "  dockerhub_repo   Docker Hub repository in format: user/image"
    echo "  project_dir      Optional: subdirectory containing Dockerfile"
    echo ""
    echo "Examples:"
    echo "  $0 username/express_app dockeruser/testing"
    echo "  $0 username/monorepo dockeruser/app backend"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    print_error "Missing required arguments"
    usage
fi

GITHUB_REPO=$1
DOCKERHUB_REPO=$2
PROJECT_DIR=${3:-""}

# Validate repository formats
if [[ ! $GITHUB_REPO =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]; then
    print_error "Invalid GitHub repository format. Expected: owner/repo"
    exit 1
fi

if [[ ! $DOCKERHUB_REPO =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]; then
    print_error "Invalid Docker Hub repository format. Expected: user/image"
    exit 1
fi

# Check if required commands exist
for cmd in git docker; do
    if ! command -v $cmd &> /dev/null; then
        print_error "$cmd is not installed. Please install it first."
        exit 1
    fi
done

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker first."
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
print_info "Created temporary directory: $TEMP_DIR"

# Cleanup function
cleanup() {
    print_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Clone the repository
print_info "Cloning repository: https://github.com/$GITHUB_REPO"
if ! git clone "https://github.com/$GITHUB_REPO.git" "$TEMP_DIR/repo" 2>&1; then
    print_error "Failed to clone repository. Please check if the repository exists and is accessible."
    exit 1
fi

# Determine build context
if [ -n "$PROJECT_DIR" ]; then
    BUILD_CONTEXT="$TEMP_DIR/repo/$PROJECT_DIR"
    print_info "Using project directory: $PROJECT_DIR"
else
    BUILD_CONTEXT="$TEMP_DIR/repo"
    print_info "Using repository root as build context"
fi

# Check if build context exists
if [ ! -d "$BUILD_CONTEXT" ]; then
    print_error "Build context directory does not exist: $BUILD_CONTEXT"
    exit 1
fi

# Find Dockerfile
DOCKERFILE_PATH=""
if [ -f "$BUILD_CONTEXT/Dockerfile" ]; then
    DOCKERFILE_PATH="$BUILD_CONTEXT/Dockerfile"
    print_info "Found Dockerfile at: $DOCKERFILE_PATH"
elif [ -f "$BUILD_CONTEXT/dockerfile" ]; then
    DOCKERFILE_PATH="$BUILD_CONTEXT/dockerfile"
    print_info "Found dockerfile at: $DOCKERFILE_PATH"
else
    print_error "No Dockerfile found in $BUILD_CONTEXT"
    exit 1
fi

# Login to Docker Hub
print_info "Logging in to Docker Hub..."
if ! docker login; then
    print_error "Docker Hub login failed"
    exit 1
fi

# Build Docker image
print_info "Building Docker image: $DOCKERHUB_REPO"
if ! docker build -t "$DOCKERHUB_REPO:latest" "$BUILD_CONTEXT"; then
    print_error "Docker build failed"
    exit 1
fi

# Tag with git commit hash if available
cd "$TEMP_DIR/repo"
if git rev-parse --short HEAD &> /dev/null; then
    GIT_HASH=$(git rev-parse --short HEAD)
    print_info "Tagging image with git hash: $GIT_HASH"
    docker tag "$DOCKERHUB_REPO:latest" "$DOCKERHUB_REPO:$GIT_HASH"
fi
cd - > /dev/null

# Push to Docker Hub
print_info "Pushing image to Docker Hub: $DOCKERHUB_REPO:latest"
if ! docker push "$DOCKERHUB_REPO:latest"; then
    print_error "Failed to push image to Docker Hub"
    exit 1
fi

# Push git hash tag if exists
if [ -n "${GIT_HASH:-}" ]; then
    print_info "Pushing image with git hash tag: $DOCKERHUB_REPO:$GIT_HASH"
    docker push "$DOCKERHUB_REPO:$GIT_HASH"
fi

print_info "✓ Successfully built and pushed Docker image!"
print_info "Image: $DOCKERHUB_REPO:latest"
if [ -n "${GIT_HASH:-}" ]; then
    print_info "Also tagged as: $DOCKERHUB_REPO:$GIT_HASH"
fi