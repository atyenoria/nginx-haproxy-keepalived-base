FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

ENV NGINX_VERSION 1.9.11-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base \
    && rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log




ENV HAPROXY_MAJOR 1.6
ENV HAPROXY_VERSION 1.6.3
ENV HAPROXY_MD5 3362d1e268c78155c2474cb73e7f03f9

# see http://sources.debian.net/src/haproxy/1.5.8-1/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN buildDeps='curl gcc libc6-dev libpcre3-dev libssl-dev make' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
    && curl -SL "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" -o haproxy.tar.gz \
    && echo "${HAPROXY_MD5}  haproxy.tar.gz" | md5sum -c \
    && mkdir -p /usr/src/haproxy \
    && tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
    && rm haproxy.tar.gz \
    && make -C /usr/src/haproxy \
        TARGET=linux2628 \
        USE_PCRE=1 PCREDIR= \
        USE_OPENSSL=1 \
        USE_ZLIB=1 \
        all \
        install-bin \
    && mkdir -p /usr/local/etc/haproxy \
    && cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
    && rm -rf /usr/src/haproxy \
    && apt-get purge -y --auto-remove $buildDeps



RUN apt-get update && apt-get install -y software-properties-common build-essential zsh git vim dnsutils
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh && \
    cp -R /root/.oh-my-zsh /laravel && \
    chsh -s /bin/zsh


RUN wget https://releases.hashicorp.com/consul-template/0.13.0/consul-template_0.13.0_linux_amd64.zip -O consul-template.zip && \
    unzip consul-template.zip && \
    mv consul-template /usr/local/bin && \
    rm consul-template.zip


