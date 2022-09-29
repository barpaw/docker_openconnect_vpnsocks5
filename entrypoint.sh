#!/bin/sh

# set time zone
cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

# run openconnect & expose socks5 proxy
(echo "${PASS}";) | openconnect --user=${USER} --passwd-on-stdin --non-inter --verbose --protocol=${PROTOCOL} --timestamp --reconnect-timeout=600 --script-tun --script "ocproxy -g -k 60 -D 9876" --os=linux-64 ${EXTRA_ARGS} ${URL}



