# Dockerized vpn proxy working as socks5 proxy (openconnect)

Dockerized [openconnect](https://www.infradead.org/openconnect/) VPN. Exposes socks5 proxy. 

## Info

This repository provides a dockerized version of openconnect. The container accepts connections to a SOCKS5 proxy, and forwards everything through the VPN.

## Supported VPNs protocols

```
Cisco AnyConnect (--protocol=anyconnect)
Array Networks AG SSL VPN (--protocol=array)
Juniper SSL VPN (--protocol=nc)
Pulse Connect Secure (--protocol=pulse
Palo Alto Networks GlobalProtect SSL VPN (--protocol=gp)
F5 Big-IP SSL VPN (--protocol=f5)
Fortinet Fortigate SSL VPN (--protocol=fortinet)
```

## Usage

- Install docker
- Edit user credentials and connection details in  ```env``` file (you can have multiple env files eg. env_cisco)
```
URL='ip:port'
USER='user'
PASS='password'
PROTOCOL='protocol eg. fortinet'
EXTRA_ARGS='extra openconnect args eg. --servercert pin-sha256:...'
SOCKS5_PROXY_PORT=2602
CONTAINER_NAME='valid docker container name eg. fortinet_vpn'
DOCKER_IMAGE_NAME='valid docker image name eg. fortinet_vpn'
TIME_ZONE='valid tzdata time zone eg. Europe/Berlin'
```
- Run ```sh run.sh *env*``` (pass path to env file as argument)

eg.

```
sh run.sh env_cisco
```
- To stop you must stop/delete container. 