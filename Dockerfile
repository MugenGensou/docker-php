FROM php:fpm-alpine3.7

RUN apk upgrade --update \
    # install deps.
    && apk add --no-cache \
    $PHPIZE_DEPS freetype-dev libpng-dev libjpeg-turbo-dev pcre-dev openssl-dev \
    freetype libpng libjpeg-turbo pcre openssl linux-headers\
    # remove unused config.
    && rm -rf /usr/local/etc/php/conf.d/* /usr/local/etc/php-fpm.d/* \
    # install extensions.
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-install -j${NPROC} gd bcmath pdo_mysql opcache\
    # intall pecl extensions.
    && pecl channel-update pecl.php.net \
    && printf "\n" | pecl install -o redis \
    && pecl install -o swoole-2.1.1 inotify yaf \
    && docker-php-ext-enable redis swoole inotify yaf \
    # remove deps & cahce.
    && pecl clear-cache && rm -rf /tmp/pear ~/.pearrc /usr/local/lib/php/doc/* /usr/local/lib/php/test \
    && apk del $PHPIZE_DEPS freetype-dev libpng-dev libjpeg-turbo-dev pcre-dev openssl-dev

COPY ["./config/php.ini", "/usr/local/etc/php/"]
COPY ["./config/conf.d/*.ini", "/usr/local/etc/php/conf.d/"]

COPY ["./config/php-fpm.conf", "/usr/local/etc/"]
COPY ["./config/php-fpm.d/*.conf", "/usr/local/etc/php-fpm.d/"]
