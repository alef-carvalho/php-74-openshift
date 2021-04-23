FROM centos:8

# add build labels
LABEL autor="Alef Carvalho <alef.carvalho@inovedados.com.br>" \
      io.k8s.description="NodeJS Nginx CentOS 8" \
      io.k8s.display-name="NodeJS Nginx CentOS 8" \
      io.openshift.tags="builder,nodejs,openshift,okd" \
      io.openshift.expose-services="8080"

# define the deployment user
ENV OPENSHIFT_USERNAME="inovedados"

# define system installation variables
ENV EPEL_REPOSITORY=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    REMI_REPOSITORY=https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# define nginx installation variables
ENV NGINX_PORT=8080

# define nano as default file editor
ENV VISUAL="nano"

# install system packages
RUN yum update -y && yum install -y \
    git \
    openssl \
    zip \
    unzip \
    curl \
    nc \
    which \
    wget \
    nano \
    nginx

# install nodejs and global npm packages
RUN yum install $EPEL_REPOSITORY yum-utils $REMI_REPOSITORY -y && \
    yum --enablerepo=remi && \
    yum update -y && \
    yum install -y nodejs && \
    npm install -g yarn cross-env

# copy nginx custom config
ADD nginx.conf /etc/nginx/nginx.conf

# fix nginx configuration to run as unprivileged user
RUN sed -i '/user  nginx;/d' /etc/nginx/nginx.conf \
    && sed -i 's,/var/run/nginx.pid,/tmp/nginx.pid,' /etc/nginx/nginx.conf \
    && sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf \
    # nginx user must own the cache and etc directory to write cache and tweak the nginx config
    #&& chown -R 1001:0 /var/cache/nginx \
    #&& chmod -R g+w /var/cache/nginx \
    && chown -R 1001:0 /etc/nginx \
    && chmod -R g+w /etc/nginx

# configure openshift user
RUN useradd inovedados && usermod -u 1001 inovedados && \
    usermod -aG 0 inovedados && \
    rm -rf /var/www/html/*

# set workdir to application files
WORKDIR /var/www/html

# switch to openshift default user
USER 1001:0

# expose port 8080 (needed by openshift)
EXPOSE 8080