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

# Validate required environment variables
REQUIRED_VARS="OPENCONNECT_URL OPENCONNECT_USER OPENCONNECT_PASSWORD OPENCONNECT_OPTIONS DOCKER_CONTAINER_NAME DOCKER_IMAGE_VERSION DOCKER_SOCKS5_PROXY_PORT"

for VAR in $REQUIRED_VARS; do
    eval "VALUE=\${$VAR}"
    if [ -z "$VALUE" ]; then
        echo "Error: $VAR is not set. Please check your environment file."
        exit 1
    fi
done

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Validate DOCKER_SOCKS5_PROXY_PORT to ensure it is a valid port number
if ! [ "${DOCKER_SOCKS5_PROXY_PORT}" -ge 1 ] 2>/dev/null || ! [ "${DOCKER_SOCKS5_PROXY_PORT}" -le 65535 ] 2>/dev/null; then
    echo "Error: DOCKER_SOCKS5_PROXY_PORT (${DOCKER_SOCKS5_PROXY_PORT}) is not a valid port number. It must be an integer between 1 and 65535."
    exit 1
fi

if [ -z "${OPENCONNECT_MFA_CODE}" ]; then
    echo "Warning: OPENCONNECT_MFA_CODE is not set. If your VPN requires MFA, the connection may fail."
fi

echo "All required environment variables are set."

# Define the base image name to avoid repetition
IMAGE_NAME="barpaw/openconnect-ocproxy"

echo "[x] Removing old \"${DOCKER_CONTAINER_NAME}\" container..."

docker rm -f "${DOCKER_CONTAINER_NAME}" || true

echo "[x] Cleaning things after the previous run..."

# Remove dangling docker images
echo "[x] Removing dangling images..."
docker image prune -f

echo "[x] Build ${IMAGE_NAME} image..."

docker build -t ${IMAGE_NAME}:${DOCKER_IMAGE_VERSION} .

# Check if the Docker image was built successfully
if ! docker images | grep -q "${IMAGE_NAME}"; then
    echo "Error: Failed to build Docker image ${IMAGE_NAME}:${DOCKER_IMAGE_VERSION}"
    exit 1
fi

# Check if the port is already in use
if lsof -i :${DOCKER_SOCKS5_PROXY_PORT} >/dev/null; then
    echo "Error: Port ${DOCKER_SOCKS5_PROXY_PORT} is already in use. Please choose a different port."
    exit 1
fi

echo "[x] Run \"${DOCKER_CONTAINER_NAME}\" container..."

docker run \
    --restart always \
    -d \
    --name "${DOCKER_CONTAINER_NAME}" \
    -e OPENCONNECT_URL="${OPENCONNECT_URL}" \
    -e OPENCONNECT_USER="${OPENCONNECT_USER}" \
    -e OPENCONNECT_PASSWORD="${OPENCONNECT_PASSWORD}" \
    -e OPENCONNECT_MFA_CODE="${OPENCONNECT_MFA_CODE}" \
    -e OPENCONNECT_OPTIONS="${OPENCONNECT_OPTIONS}" \
    -p ${DOCKER_SOCKS5_PROXY_PORT}:9876 \
    ${IMAGE_NAME}:${DOCKER_IMAGE_VERSION}

echo "[x] Done! The \"${DOCKER_CONTAINER_NAME}\" container is now running."
echo "[x] Script finished successfully at $(date)"
