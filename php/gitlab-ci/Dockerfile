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
    process \
    mbstring \
    pecl-zip \
    gd \
    ldap \
    bcmath \
    mcrypt \
    xml \
    pear \
    curl \
    redis \
    gmp

# fix permissions
RUN adduser --disabled-password --gecos "" $USER && \
    chown -R $USER:$USER /var/www

# change to low-level user
USER $USER

WORKDIR /var/www/html