FROM amd64/alpine:3.20

ENV TZ Asia/Shanghai

RUN set -x \
    && addgroup nginx \
    && adduser -S -G nginx nginx \
	&& apk add --no-cache 'su-exec>=0.2' dumb-init libstdc++ tzdata gcc g++ make autoconf automake git linux-headers libunwind libmaxminddb-dev zlib-dev openssl-dev libatomic_ops-dev perl \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
	&& mkdir -p /root/temp/ \
    && cd /root/temp/ \
    && git clone https://gitee.com/jiangjiali/ngx_cache_purge \
    && git clone https://gitee.com/jiangjiali/ngx_brotli \
    && git clone https://gitee.com/jiangjiali/ngx_http_geoip2 \
    && git clone https://gitee.com/jiangjiali/gperftools \
    && git clone https://gitee.com/jiangjiali/pcre \
    && git clone https://gitee.com/jiangjiali/nginx \
    && chmod 755 -R /root/temp/ \
    && cd /root/temp/gperftools \
    && ./configure --enable-frame-pointers --enable-libunwind --with-tcmalloc-pagesize=32 \
    && make && make install \
    && cd /root/temp/nginx \
    && ./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --add-module=../ngx_cache_purge --add-module=../ngx_http_geoip2 --add-module=../ngx_brotli --with-pcre=../pcre --with-pcre-jit --with-openssl-opt='enable-tls1_3 enable-weak-ssl-ciphers' --with-cc-opt='-O3' --with-cpu-opt=core --with-threads --with-http_v2_module --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-libatomic --with-compat --with-file-aio --with-google_perftools_module --with-stream \
    --without-http_autoindex_module --without-http_ssi_module --without-http_memcached_module --without-select_module --without-poll_module --without-http_userid_module --without-http_geo_module --without-http_geo_module --without-http_split_clients_module --without-http_fastcgi_module --without-http_uwsgi_module --without-http_scgi_module --without-http_empty_gif_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module \
    && make && make install \
    && rm -rf /root/temp/* \
    && mkdir /tmp/tcmalloc \
    && chmod 0777 /tmp/tcmalloc \
    && apk del gcc g++ make autoconf automake git linux-headers

ENV NGINX_HOME /usr/local/nginx
ENV PATH $PATH:$NGINX_HOME/sbin

STOPSIGNAL SIGTERM
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
