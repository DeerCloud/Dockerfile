#!/bin/sh

if [ ! -z "$SECRET" ]; then
  echo -e "\033[32mUsing explicitly passed mtproto-secret:\033[0m ${SECRET}"
else
  SECRET=`hexdump -n 16 -e '4/4 "%08x" 1 "\n"' /dev/urandom`
  echo -e "\033[33mGenerating random mtproto-secret:\033[0m ${SECRET}"
fi


if [ ! -z "$TAG" ]; then
  echo -e "\033[32mUsing explicitly passed proxy-tag:\033[0m ${TAG}"
else
  TAG=`hexdump -n 16 -e '4/4 "%08x" 1 "\n"' /dev/urandom`
  echo -e "\033[33mGenerating random proxy-tag:\033[0m ${TAG}"
fi


if [ ! -z "$GLOBAL_ADDR" ]; then
  echo -e "\033[32mUsing explicitly passed global-addr:\033[0m ${GLOBAL_ADDR}"
else
  GLOBAL_ADDR=`curl -s -4 "https://www.cloudflare.com/cdn-cgi/trace" | grep -Eo 'ip=\d+\.\d+\.\d+\.\d+' | awk -F '=' '{print $2}'`
  if [[ -z "$GLOBAL_ADDR" ]]; then
    echo -e "\033[31mError: Cannot determine global ip address!\033[0m"
    exit 1
  else
    echo -e "\033[33mUsing the detected global-addr:\033[0m ${GLOBAL_ADDR}"
  fi
fi


if [ ! -z "$LOCAL_ADDR" ]; then
  echo -e "\033[32mUsing explicitly passed local-addr:\033[0m ${LOCAL_ADDR}"
else
  LOCAL_ADDR=`ip route get 8.8.8.8 | head -1 | cut -d ' ' -f 8`
  if [[ -z "$LOCAL_ADDR" ]]; then
    echo -e "\033[31mError: Cannot determine local ip address!\033[0m"
    exit 2
  else
    echo -e "\033[33mUsing the detected local-addr:\033[0m ${LOCAL_ADDR}"
  fi
fi


rm -f ${MTPROXY_CONFIG_PATH}/*
curl -s ${MTPROXY_SECRET_DOWNLOAD_URL} -o ${MTPROXY_CONFIG_PATH}/proxy-secret || {
  echo -e "\033[31mError: Cannot download proxy-secret from Telegram servers.!\033[0m"
  exit 3
}
curl -s ${MTPROXY_CONFIG_DOWNLOAD_URL} -o ${MTPROXY_CONFIG_PATH}/proxy-multi.conf || {
  echo -e "\033[31mError: Cannot download proxy-multi.conf from Telegram servers.!\033[0m"
  exit 3
}

echo -e "\033[32mStarting MTProxy......\033[0m"

echo ""
echo -e "\033[32m  https://t.me/proxy?server=${GLOBAL_ADDR}&port=\033[31m443\033[32m&secret=${SECRET}\033[0m"
echo -e "\033[32m  https://t.me/proxy?server=${GLOBAL_ADDR}&port=\033[31m443\033[32m&secret=\033[31mdd\033[32m${SECRET}\033[0m"
echo ""
echo -e "\033[32m  !! replace \033[31m443\033[32m to your different port.\033[0m"
echo ""

sleep 1

mtproto-proxy \
  --user nobody \
  --port 8888 \
  --http-ports 443 \
  --mtproto-secret ${SECRET} \
  --proxy-tag ${TAG} \
  --address 0.0.0.0 \
  --nat-info "${LOCAL_ADDR}:${GLOBAL_ADDR}" \
  --aes-pwd ${MTPROXY_CONFIG_PATH}/proxy-secret \
  ${MTPROXY_CONFIG_PATH}/proxy-multi.conf
