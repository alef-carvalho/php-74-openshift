# DEFINE BUILD ARGS
ARG PHP_VERSION="8.2"
ARG PHP_XDEBUG_VERSION="3.2.2"
ARG NODE_VERSION="18.17.1"

# DEFINE BASE IMAGE
FROM php:${PHP_VERSION}-fpm-alpine

# RELOAD ARGUMENTS (MULTISTAGE BUILD)
# SEE: https://stackoverflow.com/questions/53681522/share-variable-in-multi-stage-dockerfile-arg-before-from-not-substituted
ARG PHP_VERSION
ARG PHP_XDEBUG_VERSION
ARG NODE_VERSION

# DEFINE LABELS
LABEL author="Alef Carvalho <alef.carvalho@inovedados.com.br>" \
    description="PHP + NVM + XDebug + Nginx Image"

# DEFINE ENVIRONMENT VARIABLES
ENV APP_DIR="/var/www/html" \
    PHP_DATE_TIMEZONE="America/Sao_Paulo" \
    PHP_DISPLAY_ERRORS=Off \
    PHP_DISPLAY_STARTUP_ERRORS=Off \
    PHP_CONFIG_FILE=/usr/local/etc/php/conf.d/custom.ini \
    PHP_MAX_EXECUTION_TIME=60 \
    PHP_MEMORY_LIMIT=256M \
    PHP_UPLOAD_MAX_FILESIZE=256M \
    PHP_POST_MAX_FILESIZE=256M \
    XDEBUG_TOKEN="PHPSTORM" \
    XDEBUG_VERSION=${PHP_XDEBUG_VERSION} \
    NODEJS_VERSION=${NODE_VERSION} \
    NVM_DIR="/usr/local/nvm" \
    PROFILE="/etc/profile" \
    TZ='America/Sao_Paulo' \
    ENV="/root/.ashrc"

# INSTALL LINUX PACKAGES
# See: https://github.com/nvm-sh/nvm/blob/master/README.md#installing-nvm-on-alpine-linux
RUN apk update && apk add --no-cache \
    autoconf \
    bash \
    bash-doc \
    bash-completion \
    binutils \
    ca-certificates \
    coreutils \
    curl \
    findutils \
    gcc \
    g++ \
    git \
    grep \
    htop \
    libgcc \
    linux-headers \
    postgresql-dev \
    make \
    nano \
    nginx \
    ncurses \
    python3 \
    supervisor \
    zip \
    unzip \
    util-linux \
    wget

# DEFINE SHELL FOR BUILD
SHELL ["/bin/bash", "-c"]

# INSTALL PHP EXTENSIONS
RUN pecl install redis xdebug-${XDEBUG_VERSION} \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=${XDEBUG_TOKEN}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && docker-php-ext-install bcmath pdo pdo_pgsql pdo_mysql \
    && docker-php-ext-enable redis xdebug

# INSTALL COMPOSER
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && unlink composer-setup.php

# CONFIGURE PHP
COPY ./config/php/php.ini $PHP_CONFIG_FILE
RUN sed -ri -e "s!;date.timezone =!date.timezone = "${PHP_DATE_TIMEZONE}"!g" $PHP_CONFIG_FILE && \
    sed -i -e "s/^post_max_size = 8M/post_max_size = ${PHP_POST_MAX_FILESIZE}/" ${PHP_CONFIG_FILE} && \
    sed -i -e "s/^upload_max_filesize = 2M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" ${PHP_CONFIG_FILE} && \
    sed -i -e "s/^memory_limit = 128M/memory_limit = ${PHP_MEMORY_LIMIT}/" ${PHP_CONFIG_FILE} && \
    sed -i -e "s/^max_execution_time = 30/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" ${PHP_CONFIG_FILE} && \
    sed -i -e "s/^display_errors = On/display_errors = ${PHP_DISPLAY_ERRORS}/" ${PHP_CONFIG_FILE} && \
    sed -i -e "s/^display_startup_errors = On/display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}/" ${PHP_CONFIG_FILE} && \
    sed -i -e "s/^LogLevel warn/LogLevel Error/" ${PHP_CONFIG_FILE} && \
    sed -i "/;session.save_path/c\session.save_path=\/tmp" ${PHP_CONFIG_FILE}

# INSTALL NODEJS/YARN
RUN mkdir -p ${NVM_DIR} && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install -s --latest-npm --alias=default $NODE_VERSION \
    && nvm use default

# CONFIGURE NGINX
COPY ./config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx/server.conf /etc/nginx/conf.d/server.conf

# CONFIGURE SUPERVISOR
COPY ./config/supervisor/jobs/*.ini /etc/supervisor.d/
COPY ./config/supervisor/supervisord.conf /etc/supervisord.conf

# CONFIGURE SYSTEM USER
RUN mkdir -p /run/supervisor && \
    mkdir -p /var/log/supervisor && \
    chmod g+wx /var/log/supervisor && \
    chmod g+wx /run/supervisor

# CONFIGURERE TOOLS
COPY --chmod=0755 ./scripts/tools/log.sh /usr/bin/log

# CONFIGURE STARTUP
COPY --chmod=0755 ./scripts/startup.sh /usr/bin/startup

# CONFIGURE SHELL STARTUP
RUN echo "source /etc/profile" >> /root/.ashrc

# EXPOSE PORTS
EXPOSE 8080

ENTRYPOINT ["startup"]