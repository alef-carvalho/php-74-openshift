FROM php:7.4

LABEL maintainer="Alef Carvalho <alef.carvalho@inovedados.com.br>"

# installation arguments
ENV USER=inovedados \
    PHP_COMPOSER_VERSION=2.0.12

USER root

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=$PHP_COMPOSER_VERSION && \
    rm composer-setup.php

# install system packages
RUN apt-get update && apt-get install -yq \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    build-essential \
    curl \
    git \
    gnupg2 \
    jq \
    libc-client-dev \
    openssh-client \
    unzip \
    zip \
    zlib1g-dev

# configure php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

# install php extensions
RUN docker-php-ext-install \
    soap \
    tidy \
    imap \
    opcache \
    pdo \
    xml \
    json \
    intl \
    pgsql \
    mysqlnd \
    mbstring \
    gd \
    ldap \
    bcmath \
    xml \
    pear \
    curl \
    redis \
    gmp

# install pecl extensions
RUN pecl install mcrypt-1.0.1 && \
    docker-php-ext-enable mcrypt

# fix permissions
RUN adduser --disabled-password --gecos "" $USER && \
    chown -R $USER:$USER /var/www

# change to low-level user
USER $USER

WORKDIR /var/www/html