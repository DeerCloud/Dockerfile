FROM alpine:3.8 AS builder

LABEL maintainer="metowolf <i@i-meto.com>"

ENV MTPROXY_GIT_VERSION v1
ENV MTPROXY_GIT_URL https://github.com/TelegramMessenger/MTProxy.git

COPY ./patches /patches

RUN apk upgrade \
    && apk add --virtual .build-deps \
        git \
        make \
        gcc \
        musl-dev \
        linux-headers \
        openssl-dev \
    && git clone ${MTPROXY_GIT_URL} MTProxy -b ${MTPROXY_GIT_VERSION} -c advice.detachedHead=false \
    && cd MTProxy \
    && git config --global user.email "i@i-meto.com" \
    && git config --global user.name "metowolf" \
    && git am /patches/*.patch \
    && make


FROM alpine:3.8

LABEL maintainer="metowolf <i@i-meto.com>"

ENV MTPROXY_CONFIG_PATH /etc/mtproxy
ENV MTPROXY_CONFIG_DOWNLOAD_URL https://core.telegram.org/getProxyConfig
ENV MTPROXY_SECRET_DOWNLOAD_URL https://core.telegram.org/getProxySecret
ENV SLAVES 1
ENV SECRET=
ENV TAG=
ENV LOCAL_ADDR=
ENV GLOBAL_ADDR=
ENV ARGS=

RUN apk add --no-cache curl \
    && ln -s /usr/lib/libcrypto.so.43 /usr/lib/libcrypto.so.1.0.0 \
    && mkdir ${MTPROXY_CONFIG_PATH}

COPY --from=builder /MTProxy/objs/bin/mtproto-proxy /usr/bin/mtproto-proxy
COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
