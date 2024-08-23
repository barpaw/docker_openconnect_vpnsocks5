#!/bin/sh

# Validate required environment variables
REQUIRED_VARS="OPENCONNECT_USER OPENCONNECT_PASSWORD OPENCONNECT_URL OPENCONNECT_OPTIONS"

for VAR in $REQUIRED_VARS; do
    eval "VALUE=\${$VAR}"
    if [ -z "$VALUE" ]; then
        echo "Error: ENV $VAR is not set. Please check your environment."
        exit 1
    fi
done

(echo $OPENCONNECT_PASSWORD; echo $OPENCONNECT_MFA_CODE) | openconnect --user=${OPENCONNECT_USER} --passwd-on-stdin --non-inter --verbose --timestamp --reconnect-timeout=600 --script-tun --script "ocproxy -g -k 60 -D 9876" --os=linux-64 ${OPENCONNECT_OPTIONS} ${OPENCONNECT_URL}
