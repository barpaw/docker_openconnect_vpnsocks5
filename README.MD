
![Logo](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/th5xamgrr6se0x5ro4g6.png)


# openconnect-proxy

This project aims to facilitate the setup of a secure VPN connection within a Docker container using the OpenConnect client, provides access to the VPN connection through a SOCKS5 proxy provided by ocproxy. It supports multiple VPN protocols, including Cisco's AnyConnect SSL VPN, and allows for establishing multiple simultaneous connections to supported VPNs, even those using the same protocol. Network traffic is routed through the VPN via the SOCKS5 proxy, enabling easy and secure tunneling of connections from your local environment or other applications through the VPN.

## Components Used

- [openconnect](https://gitlab.com/openconnect/openconnect) (v9.12)
- [ocproxy](https://github.com/cernekee/ocproxy) (v1.60)
## Getting Started

To set up **openconnect-proxy**, configure environment variables according to whether you're running the Docker container directly or building and running locally.Depending on whether you're running the Docker container directly or building and running locally, the configuration steps differ:

### Running with Docker

When running the Docker container directly, you can set environment variables in the docker run command. Here’s how:

1. **Prepare Environment Variables:** Include the required environment variables in the Docker run command.

```bash
docker run \
-d \
-e OPENCONNECT_URL="ip:port" \
-e OPENCONNECT_USER="user" \
-e OPENCONNECT_PASSWORD="password" \
-e OPENCONNECT_MFA_CODE='mfa_code (optional)' \
-e OPENCONNECT_OPTIONS="--protocol=<vpn_protocol>" \
--name "openconnect-proxy" \
-p <local_port>:9876 \
--restart always \
barpaw/openconnect-proxy:1.0.0
```
- Replace ``ip:port``, ``user``, ``password``, ``mfa_code``, ``<vpn_protocol>``, and ``<local_port>`` with the appropriate values for your setup.
- **Note:** Your connection may require additional options in ``OPENCONNECT_OPTIONS``. Check the [OpenConnect manual](https://www.infradead.org/openconnect/manual.html) for more flags.

### Building and Running Locally

When building and running the container locally using the ``build_and_run_locally.sh`` script, configure the environment variables in a ``env`` file. Follow these steps:

1. **Create an Environment File:** Create a .env file in the repository directory with the required environment variables. The .env file should look like this:

```
OPENCONNECT_URL='ip:port, e.g., 127.0.0.1:2000'
OPENCONNECT_USER='user'
OPENCONNECT_PASSWORD='password'
OPENCONNECT_MFA_CODE='mfa_code (optional)'
OPENCONNECT_OPTIONS='--protocol=<protocol, e.g., f5> --example_option=example'
DOCKER_CONTAINER_NAME='f5_vpn'
DOCKER_OPENCONNECT_PROXY_VERSION='1.0.0'
DOCKER_SOCKS5_PROXY_PORT=1337
```

2. **Run the Script:** Execute the script to build the Docker image and start the container with the configuration from the .env file:

```
sh build_and_run_locally.sh .env
```

- Ensure that the .env file is present in the repository directory and contains the necessary environment variables.
## Supported Protocols

OpenConnect supports the following VPN protocols:

- Cisco AnyConnect ``--protocol=anyconnect``
- Array Networks AG SSL VPN ``--protocol=array``
- Juniper SSL VPN ``--protocol=nc``
- Pulse Connect Secure ``--protocol=pulse``
- Palo Alto Networks GlobalProtect SSL VPN ``--protocol=gp``
- F5 Big-IP SSL VPN ``--protocol=f5``
- Fortinet Fortigate SSL VPN ``--protocol=fortinet``

For more details on these protocols and additional options, please refer to the OpenConnect [manual](https://www.infradead.org/openconnect/manual.html).
## Docker Hub

You can find the Docker image for **openconnect-proxy** on Docker Hub. Pull the image using the following command:

```bash
docker pull barpaw/openconnect-proxy:1.0.0
```

For more details, visit the [Docker Hub repository](https://hub.docker.com/r/barpaw/openconnect-proxy).

## License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.

