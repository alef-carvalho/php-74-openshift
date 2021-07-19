FROM centos:8

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

#install dependencies
RUN yum -y install --setopt=tsflags=nodocs java-1.8.0-openjdk unzip hostname gettext && \
    yum clean all

#download and install sonarqube
RUN curl -o sonarqube.zip -SL https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip --retry 9 --retry-max-time 0 -C - && \
    unzip sonarqube.zip && \
    mv sonarqube-${SONAR_VERSION}/* ${SONARQUBE_HOME} && \
    rm sonarqube.zip*

#copy configuration file
COPY ./config/sonar.properties ${SONARQUBE_HOME}/conf/

#change configuration file
RUN envsubst < ${SONARQUBE_HOME}/conf/sonar.properties

#copy deployer script
ADD ./scripts/run.sh /usr/bin/run-sonar

#make deployer script as executable
RUN chmod +x /usr/bin/run-sonar

#fix permissions
RUN useradd -l -u 10001 -r -g 0 -m -s /sbin/nologin \
        -c "sonarqube application user" sonarqube && \
    chown -R 10001:0 ${SONARQUBE_HOME} && \
    chmod -R g=u ${SONARQUBE_HOME}

#configure volumes
VOLUME ["${SONARQUBE_HOME}/data", "${SONARQUBE_HOME}/extensions"]

#change user to unprivileged
USER 10001

#move to workdir
WORKDIR ${SONARQUBE_HOME}

#start server
ENTRYPOINT ["run-sonar"]