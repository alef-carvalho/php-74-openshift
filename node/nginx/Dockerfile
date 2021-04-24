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
    gcc-c++ \
    make \
    tar \
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
    curl -fsSL https://rpm.nodesource.com/setup_16.x | bash - && \
    curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    yum update -y && \
    yum install -y nodejs yarn

# copy nginx custom config
ADD ./nginx.conf /etc/nginx/nginx.conf

# configure openshift user
RUN useradd inovedados && usermod -u 1001 inovedados && usermod -aG 0 inovedados && \
    mkdir "${HOME}/.npm-packages" && \
    chown -R 1001:0 /etc/nginx /usr/lib/node_modules && \
    chmod -R g+w /etc/nginx /usr/lib/node_modules && \
    rm -rf /var/www/html/* && \
    npm config set prefix "${HOME}/.npm-packages"

# update path variable
ENV NPM_PACKAGES="${HOME}/.npm-packages" \
    PATH="$PATH:$NPM_PACKAGES/bin"

# set workdir to application files
WORKDIR /var/www/html

# switch to openshift default user
USER 1001:0

# expose port 8080 (needed by openshift)
EXPOSE 8080