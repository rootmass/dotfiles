#!/bin/bash 

yum install -y make \
gcc \
openssl-devel \
pcre-devel  \
bzip2-devel \
libxml2 \
libxml2-devel \
curl-devel \
libmcrypt-devel \
libjpeg \
libjpeg-devel \
libpng \
libpng-devel \
openssl \
wget

groupadd nginx
useradd nginx -g nginx -M -s /sbin/nologin

mkdir -p /usr/local/nginx/tmp
mkdir -p /usr/local/nginx/tmp
mkdir -p /usr/local/nginx/lock

wget -c -v "http://nginx.org/download/nginx-1.11.1.tar.gz" && tar zxvf nginx-1.11.1.tar.gz && cd nginx-1.11.1

./configure \
--user=nginx \
--group=nginx \
--prefix=/usr/local/nginx \
--pid-path=/usr/local/nginx/run/nginx.pid \
--lock-path=/usr/local/nginx/lock/nginx.lock \
--with-http_ssl_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gzip_static_module \
--with-http_stub_status_module

#make && make install
