<p align="center">
<img src="https://user-images.githubusercontent.com/2666735/48941000-ad626c00-ef54-11e8-9bc7-16466a069a98.png">
</p>


<p align="center">
<a href="https://hub.docker.com/r/deercloud/mtproxy/"><img src="https://img.shields.io/docker/pulls/deercloud/mtproxy.svg?style=for-the-badge"></a>
<a href="https://hub.docker.com/r/deercloud/mtproxy/"><img src="https://img.shields.io/docker/build/deercloud/mtproxy.svg?style=for-the-badge"></a>
<img alt="License" src="https://img.shields.io/github/license/deercloud/dockerfile.svg?style=for-the-badge"/>
</p>


### Version

 - **MTProxy:** v1
 - **Alpine:** 3.8

### Pull the image

```
$ docker pull deercloud/mtproxy
```

### Start a container

```
$ docker run -p 443:443 -d --restart always deercloud/mtproxy:latest --name=mtproxy
```

This starts a container of the latest release with all the default settings, which is equivalent to

```
$ mtproto-proxy \
  --slaves 1 \
  --user nobody \
  --port 8888 \
  --http-ports 443 \
  --mtproto-secret $(random) \
  --proxy-tag $(random) \
  --address 0.0.0.0 \
  --nat-info "$(local_addr):$(global_addr)" \
  --aes-pwd /etc/mtproxy/proxy-secret \
  /etc/mtproxy/proxy-multi.conf \
  $ARGS
```

 > Note: mtproto-secret & proxy-tag will be generate by `/dev/urandom`

### Display MTProxy link

The container's log output will contain the links to paste into the Telegram app:

```
$ docker logs mtproxy

Using explicitly passed mtproto-secret: efcaec3bc7102890adb444b3d24660fb
Generating random proxy-tag: 6a34cd54d81652d9b0657c79848f144b
Using the detected global-addr: 1.1.1.1
Using the detected local-addr: 192.168.240.1
Starting MTProxy......

  https://t.me/proxy?server=1.1.1.1&port=443&secret=efcaec3bc7102890adb444b3d24660fb
  https://t.me/proxy?server=1.1.1.1&port=443&secret=ddefcaec3bc7102890adb444b3d24660fb

  !! replace 443 to your different port.
```

 > :warning: You may forward any other port to the container's 443: be sure to fix the automatic configuration links if you do so.


### With custom port

In most cases you'll want to change a thing or two, for instance the port which the server listens on. This is done by changing the -p arguments.

Here's an example to start a container that listens on 1443:

```
$ docker run -p 1443:443 -d --restart always deercloud/mtproxy:latest --name=mtproxy
```

 > :warning: DONOT change `:443` to other ports.

### With custom secret

Another thing you may want to change is the secret. To change that, you can pass your own secret as an environment variable when starting the container.

Generate a secret to be used by users to connect to your proxy.

```
$ head -c 16 /dev/urandom | xxd -ps
efcaec3bc7102890adb444b3d24660fb
```

Here's an example to start a container with `efcaec3bc7102890adb444b3d24660fb` as the secret:

```
$ docker run -e SECRET=efcaec3bc7102890adb444b3d24660fb -p 443:443 -d --restart always deercloud/mtproxy:latest --name=mtproxy
```

### With other customizations

Besides `SECRET`, the image also defines the following environment variables that you can customize:

 - `TAG`: Set proxy received tag, random by default
 - `SLAVES`: Spawn several slave workers
 - `ARGS`: Append other variables

### Use docker-compose to manage (optional)

It is very handy to use docker-compose to manage docker containers. You can download the binary at https://github.com/docker/compose/releases.

This is a sample docker-compose.yml file.

```
version: '3'

services:

  mtproxy:
    image: deercloud/mtproxy
    container_name: mtproxy
    restart: always
    environment:
      - SECRET=efcaec3bc7102890adb444b3d24660fb
      - TAG=6a34cd54d81652d9b0657c79848f144b
    ports:
      - "443:443"
```

It is highly recommended that you setup a directory tree to make things easy to manage.

```
$ mkdir -p ~/fig/mtproxy/
$ cd ~/fig/mtproxy/
$ curl -sSLO https://raw.githubusercontent.com/DeerCloud/Dockerfile/master/MTProxy/docker-compose.yml
$ docker-compose up -d
$ docker-compose ps
$ docker-compose logs
```

### Registering your proxy

Once your MTProxy server is up and running go to [@MTProxybot](https://t.me/mtproxybot) and register your proxy with Telegram to gain access to usage statistics and monetization.

### Stats

The MTProto proxy server exports internal statistics as tab-separated values over the http://127.0.0.1:8888/stats endpoint. Please note that this endpoint is available only from localhost: depending on your configuration, you may need to collect the statistics with:

```
$ docker exec mtproxy curl 127.0.0.1:8888/stats
```

## Author

**Deer Cloud** © [metowolf](https://github.com/metowolf), Released under the [MIT](./LICENSE) License.<br>

> Blog [@meto](https://i-meto.com) · GitHub [@metowolf](https://github.com/metowolf) · Twitter [@metowolf](https://twitter.com/metowolf) · Telegram Channel [@metooooo](https://t.me/metooooo)
