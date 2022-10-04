FROM alpine:3.16.2

ENV USER=docker
ENV UID=12345
ENV GID=23456

RUN addgroup -S "$USER" && \
    adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

RUN apk update && apk add --no-cache ca-certificates tzdata libevent-dev autoconf automake gcc binutils make alpine-sdk linux-headers libtool xdg-utils vpnc gettext openssl-dev libxml2-dev && rm -rf /var/lib/apt/lists

# build and install openconnect 
WORKDIR /
RUN wget https://gitlab.com/openconnect/openconnect/-/archive/v9.01/openconnect-v9.01.zip -O openconnect-v9.01.zip && unzip openconnect-v9.01.zip

WORKDIR /openconnect-v9.01
RUN sh autogen.sh
RUN sh configure
RUN make install

# build and install ocproxy 
WORKDIR /
RUN wget https://github.com/cernekee/ocproxy/archive/refs/tags/v1.60.zip -O ocproxy-1.60.zip && unzip ocproxy-1.60.zip

WORKDIR /ocproxy-1.60
RUN sh autogen.sh
RUN sh configure
RUN make install

WORKDIR /vpn
COPY ./entrypoint.sh .

USER docker

EXPOSE 9876

ENTRYPOINT ["/vpn/entrypoint.sh"]
