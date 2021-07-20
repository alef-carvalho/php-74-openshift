FROM centos:8

# define additional repositories
ENV EPEL_REPOSITORY=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    REMI_REPOSITORY=https://rpms.remirepo.net/enterprise/remi-release-8.rpm

#define openshift config variables
ENV SONAR_VERSION=9.0.0.45539 \
    SONARQUBE_HOME=/opt/sonarqube \
    SONARQUBE_WEB_PORT=9000 \
    SONARQUBE_WEB_HOST="sonar.web.host" \
    SONARQUBE_WEB_CONTEXT="/sonarqube" \
    SONARQUBE_DATABASE_HOST="192.168.0.1" \
    SONARQUBE_DATABASE_USERNAME="sonarqube" \
    SONARQUBE_DATABASE_PASSWORD="sonarqube" \
    JAVA_HOME=/usr/lib/jvm/jre \
    LANG=en_US.utf8

#define openshift tags
LABEL name="sonarqube" \
      io.k8s.description="SonarQube" \
      io.k8s.display-name="SonarQube" \
      io.openshift.expose-services="9000:9000" \
      io.openshift.tags="sonarqube,sonar,sonarsource"

#expose port to openshift
EXPOSE 9000

# install php, nodejs and extensions
RUN yum install $EPEL_REPOSITORY yum-utils $REMI_REPOSITORY -y && \
    yum --enablerepo=remi && \
    yum update -y && \
    yum install -y --setopt=tsflags=nodocs java-1.8.0-openjdk zip unzip wget nano hostname gettext supervisor && \
    yum clean all

# copy supervisor configuration files
COPY supervisor/base.conf /etc/supervisord.conf
COPY supervisor/jobs/*.ini /etc/supervisord.d/

#download and install sonarqube
RUN cd /opt && \
    mkdir ${SONARQUBE_HOME} && \
    curl -o sonarqube.zip -SL https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip --retry 9 --retry-max-time 0 -C - && \
    unzip sonarqube.zip && \
    mv sonarqube-${SONAR_VERSION}/* ${SONARQUBE_HOME} && \
    rm sonarqube.zip

#copy configuration file
COPY ./config/sonar.properties ${SONARQUBE_HOME}/conf/

#copy deployer script
ADD ./scripts/run.sh /usr/bin/run-sonar

#make deployer script as executable
RUN chmod +x /usr/bin/run-sonar

# configure openshift user
RUN useradd inovedados && usermod -u 1001 inovedados && usermod -aG 0 inovedados && \
    mkdir -p /var/log/supervisor /var/log/inovedados && \
    chown -R 1001 /run/supervisor /var/log/supervisor /var/log/inovedados ${SONARQUBE_HOME} && \
    chgrp -R 0 /run/supervisor /var/log/supervisor /var/log/inovedados ${SONARQUBE_HOME} && \
    chmod -R g=u /run/supervisor /var/log/supervisor /var/log/inovedados ${SONARQUBE_HOME} && \
    chmod gu+rw /var/run && \
    systemctl enable supervisord

#configure volumes
VOLUME ["${SONARQUBE_HOME}/data", "${SONARQUBE_HOME}/extensions"]

#change user to unprivileged
USER 10001

#move to workdir
WORKDIR ${SONARQUBE_HOME}

#start server
ENTRYPOINT ["run-sonar"]