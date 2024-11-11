FROM alpine:3.20.2

ARG USER=docker

ARG OPENCONNECT_VERSION=v9.12
ARG OCPROXY_VERSION=v1.60

RUN addgroup -S "$USER" && \
    adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "12345" \
    "$USER"

RUN apk update && apk add --no-cache \
    ca-certificates \
    tzdata \
    libevent-dev \
    autoconf \
    automake \
    gcc \
    binutils \
    make \
    alpine-sdk \
    linux-headers \
    libtool \
    xdg-utils \
    vpnc \
    gettext \
    openssl-dev \
    libxml2-dev \
    git \
    zlib \
    pkgconf \
    p11-kit \
    libproxy \
    libtasn1 \
    oath-toolkit-libpskc \
    pcsc-lite-libs

RUN mkdir -p /openconnect-proxy

RUN apk info -vv > /openconnect-proxy/installed-packages.txt

# download source code && build && install openconnect 
WORKDIR /openconnect-proxy
RUN git clone --branch $OPENCONNECT_VERSION https://gitlab.com/openconnect/openconnect.git openconnect-$OPENCONNECT_VERSION && \
    cd /openconnect-proxy/openconnect-$OPENCONNECT_VERSION && \
    sh autogen.sh && \
    sh configure && \
    make install

# download source code && build && install ocproxy 
WORKDIR /openconnect-proxy
RUN git clone --branch $OCPROXY_VERSION https://github.com/cernekee/ocproxy.git ocproxy-$OCPROXY_VERSION && \
    cd /openconnect-proxy/ocproxy-$OCPROXY_VERSION && \
    sh autogen.sh && \
    sh configure && \
    make install

WORKDIR /openconnect-proxy
COPY ./entrypoint.sh .

USER $USER

EXPOSE 9876

ENTRYPOINT ["/openconnect-proxy/entrypoint.sh"]
