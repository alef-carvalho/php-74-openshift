FROM php:7.4-apache as builder

# Essentials
RUN apt-get update -y && \
    apt-get install -y curl zip unzip nginx supervisor wget

# Install PHP Extension Manager
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Installing PHP Extensions
RUN install-php-extensions \
    bcmath \
    ctype \
    fileinfo \
    json \
    mbstring \
    openssl \
    pdo \
    tokenizer \
    xml \
    opcache \
    zip \
    curl \
    dom \
    redis \
    imagick \
    xdebug

# Installing Composer
RUN install-php-extensions @composer-2.0.2

# Configure Supervisor
COPY ./conf/supervisor/supervisord.conf /etc/supervisord.conf
COPY ./conf/supervisor/jobs/*.ini /etc/supervisord.d/

# Configure PHP
COPY ./conf/php/php.ini /usr/local/etc/php/php.ini

# Create log files
RUN mkdir -p /var/log/supervisor /run/supervisor

# copy application files
COPY ./test /var/www/html

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisord.conf"]