#!/bin/bash

# Copyright 2015 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e

export NGINX_VERSION=1.13.3
export NDK_VERSION=0.3.0
export VTS_VERSION=0.1.15
export SETMISC_VERSION=0.31
export LUA_VERSION=0.10.8
export STICKY_SESSIONS_VERSION=d3d0ee282f2e4e22d1202c83f62ca05228b94a33
export LUA_CJSON_VERSION=2.1.0.4
export LUA_RESTY_HTTP_VERSION=0.07
export LUA_UPSTREAM_VERSION=0.06
export LUA_SOCKET_VERSION=2.0.2
export LUA_GUMBO_VERSION=0.4
export LUA_ROCKS_VERSION=2.4.2
export MORE_HEADERS_VERSION=0.32
export NGINX_DIGEST_AUTH=7955af9c77598c697ac292811914ce1e2b3b824c
export NGINX_SUBSTITUTIONS=bc58cb11844bc42735bbaef7085ea86ace46d05b

export BUILD_PATH=/tmp/build

ARCH=$(uname -p)

get_src()
{
  hash="$1"
  url="$2"
  f=$(basename "$url")

  curl -sSLk "$url" -o "$f"
  echo "$hash  $f" | sha256sum -c - || exit 10
  tar xzf "$f"
  rm -rf "$f"
}

mkdir -p "$BUILD_PATH"
cd "$BUILD_PATH"

if [[ ${ARCH} == "ppc64le" ]]; then
  apt-get update && apt-get install --no-install-recommends -y software-properties-common && \
    add-apt-repository -y ppa:ibmpackages/luajit
  apt-get update && apt-get install --no-install-recommends -y lua5.1 lua5.1-dev
fi

# install required packages to build
apt-get update && apt-get install --no-install-recommends -y \
  bash \
  build-essential \
  curl ca-certificates \
  libgeoip1 \
  libgeoip-dev \
  patch \
  libpcre3 \
  libpcre3-dev \
  libssl-dev \
  zlib1g \
  zlib1g-dev \
  libaio1 \
  libaio-dev \
  luajit \
  openssl \
  libluajit-5.1 \
  libluajit-5.1-dev \
  libgumbo1 \
  libgumbo-dev \
  unzip \
  linux-headers-generic || exit 1

chmod +x /usr/lib/x86_64-linux-gnu/libgumbo.so.1.0.0
ln -s /usr/lib/x86_64-linux-gnu/libgumbo.so.1.0.0 /usr/local/lib/libgumbo.so

# download, verify and extract the source files
get_src eef88c2429c715a7beb921e4b1ba571dddb7c74a250fbb0d3cc0d4be7a5865d9 \
        "https://github.com/luarocks/luarocks/archive/v$LUA_ROCKS_VERSION.tar.gz"

get_src 5b73f98004c302fb8e4a172abf046d9ce77739a82487e4873b39f9b0dcbb0d72 \
        "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"

get_src 88e05a99a8a7419066f5ae75966fb1efc409bad4522d14986da074554ae61619 \
        "https://github.com/simpl/ngx_devel_kit/archive/v$NDK_VERSION.tar.gz"

get_src 97946a68937b50ab8637e1a90a13198fe376d801dc3e7447052e43c28e9ee7de \
        "https://github.com/openresty/set-misc-nginx-module/archive/v$SETMISC_VERSION.tar.gz"

get_src 5112a054b1b1edb4c0042a9a840ef45f22abb3c05c68174e28ebf483164fb7e1 \
        "https://github.com/vozlt/nginx-module-vts/archive/v$VTS_VERSION.tar.gz"

get_src d67449c71051b3cc2d6dd60df0ae0d21fca08aa19c9b30c5b95ee21ff38ef8dd \
        "https://github.com/openresty/lua-nginx-module/archive/v$LUA_VERSION.tar.gz"

get_src 5417991b6db4d46383da2d18f2fd46b93fafcebfe87ba87f7cfeac4c9bcb0224 \
        "https://github.com/openresty/lua-cjson/archive/$LUA_CJSON_VERSION.tar.gz"

get_src 1c6aa06c9955397c94e9c3e0c0fba4e2704e85bee77b4512fb54ae7c25d58d86 \
        "https://github.com/pintsized/lua-resty-http/archive/v$LUA_RESTY_HTTP_VERSION.tar.gz"

get_src c6d9dab8ea1fc997031007e2e8f47cced01417e203cd88d53a9fe9f6ae138720 \
        "https://github.com/openresty/headers-more-nginx-module/archive/v$MORE_HEADERS_VERSION.tar.gz"

get_src 55475fe4f9e4b5220761269ccf0069ebb1ded61d7e7888f9c785c651cff3d141 \
        "https://github.com/openresty/lua-upstream-nginx-module/archive/v$LUA_UPSTREAM_VERSION.tar.gz"

get_src 6ec8311d83f0adc3dd34f9f0021e5f5f4224d6d048203b55a15b624565f77eba \
        "https://github.com/danielqsj/nginx-sticky-module-ng/archive/$STICKY_SESSIONS_VERSION.tar.gz"

get_src 9b1d0075df787338bb607f14925886249bda60b6b3156713923d5d59e99a708b \
        "https://github.com/atomx/nginx-http-auth-digest/archive/$NGINX_DIGEST_AUTH.tar.gz"

get_src 8eabbcd5950fdcc718bb0ef9165206c2ed60f67cd9da553d7bc3e6fe4e338461 \
        "https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/$NGINX_SUBSTITUTIONS.tar.gz"

get_src beeae6296df777508bacde1bb307c9d93311c20d2b76e96b66822347c2329eba \
        "https://craigbarnes.gitlab.io/lua-gumbo/dist/lua-gumbo-$LUA_GUMBO_VERSION.tar.gz"

get_src 4fd9c775cfd98841299851e29b30176caf289370fea1ff1e00bb67c2d6842ca6 \
        "http://files.luaforge.net/releases/luasocket/luasocket/luasocket-$LUA_SOCKET_VERSION/luasocket-$LUA_SOCKET_VERSION.tar.gz"

#https://blog.cloudflare.com/optimizing-tls-over-tcp-to-reduce-latency/
curl -sSL -o nginx__dynamic_tls_records.patch https://raw.githubusercontent.com/cloudflare/sslconfig/master/patches/nginx__1.11.5_dynamic_tls_records.patch

# https://github.com/openresty/lua-nginx-module/issues/1016
curl -sSL -o patch-src-ngx_http_lua_headers.c.diff https://raw.githubusercontent.com/macports/macports-ports/master/www/nginx/files/patch-src-ngx_http_lua_headers.c.diff
cd "$BUILD_PATH/lua-nginx-module-$LUA_VERSION"
patch -p1 < $BUILD_PATH/patch-src-ngx_http_lua_headers.c.diff

# build luarocks
cd "$BUILD_PATH/luarocks-$LUA_ROCKS_VERSION"
./configure --lua-suffix=jit --with-lua-include=/usr/include/luajit-2.0 || exit 1 \
&& make build || exit 1 \
&& make install || exit 1

# build nginx
cd "$BUILD_PATH/nginx-$NGINX_VERSION"

echo "Applying tls nginx patches..."
patch -p1 < $BUILD_PATH/nginx__dynamic_tls_records.patch

WITH_FLAGS="--with-debug \
  --with-pcre-jit \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_realip_module \
  --with-http_auth_request_module \
  --with-http_addition_module \
  --with-http_dav_module \
  --with-http_geoip_module \
  --with-http_gzip_static_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-stream \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-threads"

if [[ ${ARCH} != "armv7l" || ${ARCH} != "aarch64" ]]; then
  WITH_FLAGS+=" --with-file-aio"
fi

CC_OPT='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4'

if [[ ${ARCH} == "x86_64" ]]; then
  CC_OPT+=' -m64 -mtune=generic'
fi

./configure \
  --prefix=/usr/share/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --http-log-path=/var/log/nginx/access.log \
  --error-log-path=/var/log/nginx/error.log \
  --lock-path=/var/lock/nginx.lock \
  --pid-path=/run/nginx.pid \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --http-scgi-temp-path=/var/lib/nginx/scgi \
  --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
  ${WITH_FLAGS} \
  --without-mail_pop3_module \
  --without-mail_smtp_module \
  --without-mail_imap_module \
  --without-http_uwsgi_module \
  --without-http_scgi_module \
  --with-cc-opt="${CC_OPT}" \
  --add-module="$BUILD_PATH/ngx_devel_kit-$NDK_VERSION" \
  --add-module="$BUILD_PATH/set-misc-nginx-module-$SETMISC_VERSION" \
  --add-module="$BUILD_PATH/nginx-module-vts-$VTS_VERSION" \
  --add-module="$BUILD_PATH/lua-nginx-module-$LUA_VERSION" \
  --add-module="$BUILD_PATH/headers-more-nginx-module-$MORE_HEADERS_VERSION" \
  --add-module="$BUILD_PATH/nginx-http-auth-digest-$NGINX_DIGEST_AUTH" \
  --add-module="$BUILD_PATH/ngx_http_substitutions_filter_module-$NGINX_SUBSTITUTIONS" \
  --add-module="$BUILD_PATH/nginx-sticky-module-ng-$STICKY_SESSIONS_VERSION" \
  --add-module="$BUILD_PATH/lua-upstream-nginx-module-$LUA_UPSTREAM_VERSION" || exit 1 \
  && make || exit 1 \
  && make install || exit 1

echo "Installing CJSON module"
cd "$BUILD_PATH/lua-cjson-$LUA_CJSON_VERSION"

if [[ ${ARCH} == "ppc64le" ]];then
  LUA_DIR=/usr/include/luajit-2.1
else
  LUA_DIR=/usr/include/luajit-2.0
fi
make LUA_INCLUDE_DIR=${LUA_DIR} && make install

echo "Installing lua socket module"
cd "$BUILD_PATH/luasocket-$LUA_SOCKET_VERSION"
make LUAINC=-I${LUA_DIR} && make install

echo "Installing lua gumbo module"
cd "$BUILD_PATH/lua-gumbo-$LUA_GUMBO_VERSION"
make LUA_CFLAGS=-I${LUA_DIR} LUA_PC=luajit && make check LUA_PC=luajit LUA=`which luajit` && make install LUA_PC=luajit LUA_LMOD_DIR=/usr/local/share/lua/5.1 LUA_CMOD_DIR=/usr/local/lib/lua/5.1

echo "Installing lua-resty-http module"
# copy lua module
cd "$BUILD_PATH/lua-resty-http-$LUA_RESTY_HTTP_VERSION"
sed -i 's/resty.http_headers/http_headers/' $BUILD_PATH/lua-resty-http-$LUA_RESTY_HTTP_VERSION/lib/resty/http.lua
cp $BUILD_PATH/lua-resty-http-$LUA_RESTY_HTTP_VERSION/lib/resty/http.lua /usr/local/lib/lua/5.1
cp $BUILD_PATH/lua-resty-http-$LUA_RESTY_HTTP_VERSION/lib/resty/http_headers.lua /usr/local/lib/lua/5.1

# Install lua PCRE module
cd "$BUILD_PATH"
luarocks install lrexlib-pcre || exit 1

echo "Cleaning..."

cd /

apt-mark unmarkauto \
  bash \
  curl ca-certificates \
  libgeoip1 \
  libpcre3 \
  zlib1g \
  libaio1 \
  luajit \
  libluajit-5.1-2 \
  xz-utils \
  geoip-bin \
  libgumbo1 \
  openssl

if [[ ${ARCH} == "ppc64le" ]]; then
  apt-mark unmarkauto liblua5.1-0
fi

apt-get remove -y --purge \
  build-essential \
  gcc-5 \
  cpp-5 \
  libgeoip-dev \
  libpcre3-dev \
  libssl-dev \
  zlib1g-dev \
  libaio-dev \
  libluajit-5.1-dev \
  linux-libc-dev \
  perl-modules-5.22 \
  libgumbo-dev \
  unzip \
  linux-headers-generic

apt-get autoremove -y

mkdir -p /var/lib/nginx/body /usr/share/nginx/html

mv /usr/share/nginx/sbin/nginx /usr/sbin

rm -rf "$BUILD_PATH"
rm -Rf /usr/share/man /usr/share/doc
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*

# Download of GeoIP databases
curl -sSL -o /etc/nginx/GeoIP.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz \
  && curl -sSL -o /etc/nginx/GeoLiteCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
  && gunzip /etc/nginx/GeoIP.dat.gz \
  && gunzip /etc/nginx/GeoLiteCity.dat.gz
