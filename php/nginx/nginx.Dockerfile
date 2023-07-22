# DEFINE BUILD ARGS
ARG PHP_VERSION="8.2"
ARG PHP_XDEBUG_VERSION="3.2.2"

# DEINE BASE IMAGE
FROM php:${PHP_VERSION}-fpm-alpine

# DEFINE LABELS
LABEL author="Alef Carvalho <alef.carvalho@inovedados.com.br>" \
    description=""

# DEFINE ENVIRONMENT VARIABLES
ENV PHP_COMPOSER_VERSION=2.0.12 \
    PHP_DATE_TIMEZONE="America/Sao_Paulo" \
    PHP_POST_MAX_FILESIZE=256M \
    PHP_UPLOAD_MAX_FILESIZE=256M \
    PHP_MEMORY_LIMIT=256M \
    PHP_MAX_EXECUTION_TIME=90 \
    PHP_DISPLAY_ERRORS=Off \
    PHP_DISPLAY_STARTUP_ERRORS=Off \
    PHP_CONFIG_FILE=/usr/local/etc/php/conf.d/app.ini \
    PHP_XDEBUG_TOKEN="PHPSTORM"

RUN echo "BUILDING PHP-${PHP_VERSION} IMAGE"

# INSTALL LINUX PACKAGES
RUN apk --update --no-cache add \
    autoconf \
    curl \
    g++ \
    git \
    htop \
    linux-headers \
    postgresql-dev \
    make \
    supervisor \
    zip \
    unzip \
    wget

# INSTALL XDEBUG
RUN pecl install redis xdebug-${XDEBUG_VERSION} \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=${PHP_XDEBUG_TOKEN}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# INSTALL PHP EXTENSIONS
RUN docker-php-ext-install bcmath pdo pdo_pgsql pdo_mysql \
    && docker-php-ext-enable redis xdebug

# INSTALL COMPOSER
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && unlink composer-setup.php

# INSTALL NODEJS/YARN

# CONFIGURE NGINX
COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx/server.conf /etc/nginx/conf.d/server.conf

# CONFIGURE SUPERVISOR
COPY ./config/supervisor/*.ini /etc/supervisor.d/

# CONFIGURE PHP
RUN sed -ri -e "s!;date.timezone =!date.timezone = "$PHP_DATE_TIMEZONE"!g" $PHP_CONFIG_FILE && \
    sed -i -e "s/^post_max_size = 8M/post_max_size = $PHP_POST_MAX_FILESIZE/" $PHP_CONFIG_FILE && \
    sed -i -e "s/^upload_max_filesize = 2M/upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE/" $PHP_CONFIG_FILE && \
    sed -i -e "s/^memory_limit = 128M/memory_limit = $PHP_MEMORY_LIMIT/" $PHP_CONFIG_FILE && \
    sed -i -e "s/^max_execution_time = 30/max_execution_time = $PHP_MAX_EXECUTION_TIME/" $PHP_CONFIG_FILE && \
    sed -i -e "s/^display_errors = On/display_errors = $PHP_DISPLAY_ERRORS/" $PHP_CONFIG_FILE && \
    sed -i -e "s/^display_startup_errors = On/display_startup_errors = $PHP_DISPLAY_STARTUP_ERRORS/" $PHP_CONFIG_FILE && \
    sed -i -e "s/^LogLevel warn/LogLevel Error/" $PHP_CONFIG_FILE && \
    sed -i "/;session.save_path/c\session.save_path=\/tmp" $PHP_CONFIG_FILE

# CONFIGURE COMMANDS
COPY --chmod=0755 ./scripts/*.sh /usr/local/bin

EXPOSE 8080

CMD ["php-fpm"]