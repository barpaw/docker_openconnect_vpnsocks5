FROM alpine:3.20.2

ENV USER=docker

ENV OPENCONNECT_VERSION=v9.12
ENV OCPROXY_VERSION=v1.60

RUN addgroup -S "$USER" && \
    adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "12345" \
    "$USER"

RUN apk update && apk add --no-cache \
    ca-certificates=20240705-r0 \
    tzdata=2024a-r1 \
    libevent-dev=2.1.12-r7 \
    autoconf=2.72-r0 \
    automake=1.16.5-r2 \
    gcc=13.2.1_git20240309-r0 \
    binutils=2.42-r0 \
    make=4.4.1-r2 \
    alpine-sdk=1.0-r1 \
    linux-headers=6.6-r0 \
    libtool=2.4.7-r3 \
    xdg-utils=1.2.1-r0 \
    vpnc=0.5.3-r10 \
    gettext=0.22.5-r0 \
    openssl-dev=3.3.1-r3 \
    libxml2-dev=2.12.7-r0 \
    git=2.45.2-r0 \
    zlib=1.3.1-r1 \
    pkgconf=2.2.0-r0 \
    p11-kit=0.25.3-r0 \
    libproxy=0.5.6-r0 \
    libtasn1=4.19.0-r2 \
    oath-toolkit-libpskc=2.6.11-r0 \
    pcsc-lite-libs=2.2.3-r0

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
