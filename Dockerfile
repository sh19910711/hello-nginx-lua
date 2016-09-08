FROM alpine:3.4

RUN apk update
RUN apk upgrade
RUN apk add \
  alpine-sdk \
  curl \
  pcre-dev \
  zlib-dev \
  luajit-dev

# nginx with lua module
ENV NGINX_VERSION="1.10.1"
ENV NGX_DEVEL_KIT_VERSION="0.3.0"
ENV NGX_LUA_VERSION="0.10.6"

RUN mkdir -p /usr/src
WORKDIR /usr/src

# ngx_devel_kit
RUN curl -SL https://github.com/simpl/ngx_devel_kit/archive/v$NGX_DEVEL_KIT_VERSION.tar.gz > ngx_devel_kit-v$NGX_DEVEL_KIT_VERSION.tar.gz
RUN tar zxvf ngx_devel_kit-v$NGX_DEVEL_KIT_VERSION.tar.gz

# ngx_lua
RUN curl -SL https://github.com/openresty/lua-nginx-module/archive/v$NGX_LUA_VERSION.tar.gz > lua-nginx-module-v$NGX_LUA_VERSION.tar.gz
RUN tar zxvf lua-nginx-module-v$NGX_LUA_VERSION.tar.gz

# nginx with lua
RUN curl -SL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz > nginx-$NGINX_VERSION.tar.gz
RUN tar zxvf nginx-$NGINX_VERSION.tar.gz
WORKDIR /usr/src/nginx-$NGINX_VERSION
RUN ls /usr/src/ngx_devel_kit-$NGX_DEVEL_KIT_VERSION
RUN ./configure \
  --prefix=/usr/local \
  --add-module=/usr/src/ngx_devel_kit-$NGX_DEVEL_KIT_VERSION \
  --add-module=/usr/src/lua-nginx-module-$NGX_LUA_VERSION
RUN make
RUN make install

COPY etc/nginx /etc/nginx
COPY lib /lib/nginx-lua
EXPOSE 80

# test nginx.conf
RUN /usr/local/sbin/nginx -t -c /etc/nginx/nginx.conf

CMD ["/usr/local/sbin/nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]
