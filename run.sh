#!/bin/sh

set -e

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
. "${SCRIPT_PATH}/$1"


echo "[x] Removing VPN container..."

sudo docker rm -f "${CONTAINER_NAME}"

echo "[x] Cleaning things after the previous run"

#Remove dangling docker images
if [[ $(docker images -qa -f 'dangling=true') ]]; then
    sudo docker rmi $(docker images -qa -f 'dangling=true')
fi

echo "[x] Build VPN container image..."

sudo docker build -t proxyvpn/${DOCKER_IMAGE_NAME} .

echo "[x] Run VPN container..."

sudo docker run \
--restart always \
-d \
--cap-add NET_ADMIN \
--name "${CONTAINER_NAME}" \
-e URL="${URL}" \
-e USER="${USER}" \
-e PASS="${PASS}" \
-e PROTOCOL="${PROTOCOL}" \
-e EXTRA_ARGS="${EXTRA_ARGS}" \
-e TIME_ZONE="${TIME_ZONE}" \
-p ${SOCKS5_PROXY_PORT}:9876 \
proxyvpn/${DOCKER_IMAGE_NAME}:latest

