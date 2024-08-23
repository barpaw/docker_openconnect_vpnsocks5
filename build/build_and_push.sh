#!/bin/sh

set -e

# Ensure that the script is called with exactly one argument (the env file)
if [ "$#" -ne 1 ]; then
    echo "Usage: sh $0 <env-file>"
    exit 1
fi

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
ENV_FILE="${SCRIPT_PATH}/$1"

# Check if the environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: File with envs not found at $ENV_FILE."
    exit 1
fi

# Source the environment variables
. "$ENV_FILE"

# Check if Dockerfile exists
if [ ! -f Dockerfile ]; then
    echo "Error: Dockerfile not found in the current directory."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if DOCKER_IMAGE_VERSION is set
if [ -z "${DOCKER_IMAGE_VERSION}" ]; then
    echo "Error: DOCKER_IMAGE_VERSION is not set in $ENV_FILE. Example: '1.0.0'"
    exit 1
fi

# Check internet connection
if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "Error: Network is not available. Please check your connection."
    exit 1
fi

# Define the base image name to avoid repetition
IMAGE_NAME="barpaw/openconnect-ocproxy"

echo "[x] Building images..."

# Build for arm64 platform
echo "[x] Build image for arm64 platform..."
docker build -t ${IMAGE_NAME}-arm64:${DOCKER_IMAGE_VERSION} -t ${IMAGE_NAME}-arm64:latest --no-cache --platform linux/arm64/v8 .
# Build for amd64 platform
echo "[x] Build image for amd64 platform..."
docker build -t ${IMAGE_NAME}-amd64:${DOCKER_IMAGE_VERSION} -t ${IMAGE_NAME}-amd64:latest --no-cache --platform linux/amd64 .
echo "[x] Pushing images..."

# Push arm64 image
echo "[x] Pushing ${IMAGE_NAME}-arm64:${DOCKER_IMAGE_VERSION} image..."
docker push ${IMAGE_NAME}-arm64:${DOCKER_IMAGE_VERSION}
docker push ${IMAGE_NAME}-arm64:latest

# Push amd64 image
echo "[x] Pushing ${IMAGE_NAME}-amd64:${DOCKER_IMAGE_VERSION} image..."
docker push ${IMAGE_NAME}-amd64:${DOCKER_IMAGE_VERSION}
docker push ${IMAGE_NAME}-amd64:latest

echo "[x] Creating docker manifest..."

# Create the manifest
docker manifest create ${IMAGE_NAME}:${DOCKER_IMAGE_VERSION} \
    ${IMAGE_NAME}-arm64:${DOCKER_IMAGE_VERSION} \
    ${IMAGE_NAME}-amd64:${DOCKER_IMAGE_VERSION} --amend

# Create the manifest for latest
docker manifest create ${IMAGE_NAME}:latest \
    ${IMAGE_NAME}-arm64:latest \
    ${IMAGE_NAME}-amd64:latest --amend

echo "[x] Pushing docker manifest..."

# Push the manifest
docker manifest push ${IMAGE_NAME}:${DOCKER_IMAGE_VERSION} 
docker manifest push ${IMAGE_NAME}:latest

echo "[x] Done! Script finished successfully at $(date)"
