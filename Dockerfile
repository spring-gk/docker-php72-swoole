FROM php:7.2-alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS linux-headers tzdata \
    && apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev gettext-dev openldap-dev \
    libxml2-dev libzip-dev libmcrypt-dev libmemcached-dev hiredis hiredis-dev inotify-tools \
    && docker-php-ext-install -j$(nproc) bcmath gd gettext pdo_mysql mysqli ldap pcntl soap sockets sysvsem xmlrpc \
    && curl -fsSL https://pecl.php.net/get/swoole-4.2.2.tgz -o swoole-4.2.2.tgz \
    && tar -xf swoole-4.2.2.tgz \
    && rm -rf swoole-4.2.2.tgz \
    && ( \
        cd swoole-4.2.2 \
        && phpize \
        && ./configure --enable-async-redis \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -rf swoole-4.2.2 \
    && pecl install mcrypt-1.0.1 \
    && pecl install memcached-3.0.4 \
    && pecl install redis-4.0.2 \
    && pecl install mongodb-1.5.3 \
    && pecl install yaf-3.0.7 \
    && pecl install yac-2.0.2 \
    && pecl install zip-1.15.2 \
    && pecl install inotify-2.0.0 \
    && docker-php-ext-enable swoole mcrypt memcached redis mongodb yaf yac zip inotify \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
    && echo "Asia/Shanghai" > /etc/timezone \
    apk del .phpize-deps freetype-dev libpng-dev libjpeg-turbo-dev gettext-dev openldap-dev libxml2-dev libzip-dev libmcrypt-dev libmemcached-dev

# Install php composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && php -r "unlink('composer-setup.php');" \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org

# Make dir
RUN mkdir -p /data/logs/php /data/cache/upload_tmp
COPY php.ini /usr/local/etc/php/php.ini

