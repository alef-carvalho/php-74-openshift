FROM sonarqube:latest

ENV SONAR_VERSION=9.0.0.45539 \
    SONARQUBE_HOME=/opt/sonarqube \
    # Database configuration
    # Defaults to using H2
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL="" \
    LANG=en_US.utf8 \
    JAVA_HOME=/usr/lib/jvm/jre

# Http port
EXPOSE 9000

LABEL name="sonarqube"
      io.k8s.description="SonarQube" \
      io.k8s.display-name="SonarQube" \
      io.openshift.expose-services="9000:9000" \
      io.openshift.tags="sonarqube,sonar,sonarsource"

#install dependencies
RUN yum -y install --setopt=tsflags=nodocs java-1.8.0-openjdk unzip hostname && \
    yum clean all

#download and install sonarqube
RUN cd /opt && \
    curl -o sonarqube.zip -SL https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip --retry 9 --retry-max-time 0 -C - && \
    unzip sonarqube.zip && \
    mv sonarqube-${SONAR_VERSION} sonarqube && \
    rm sonarqube.zip* && \
    rm -rf ${SONARQUBE_HOME}/bin/*

#copy configuration file
COPY sonar.properties ${SONARQUBE_HOME}/conf/

#copy deployer script
COPY run.sh ${SONARQUBE_HOME}/bin/run-sonar

#make deployer script as executable
RUN chmod +x /usr/bin/deploy

#set the environment path
ENV PATH=$PATH:${SONARQUBE_HOME}/bin

#fix permissions
RUN useradd -l -u 10001 -r -g 0 -m -s /sbin/nologin \
        -c "sonarqube application user" sonarqube && \
    chown -R 10001:0 ${SONARQUBE_HOME} && \
    chmod -R g=u ${SONARQUBE_HOME} && \
    chmod ug+x ${SONARQUBE_HOME}/bin/run.sh

#configure volumes
VOLUME ["${SONARQUBE_HOME}/data", "${SONARQUBE_HOME}/extensions"]

#change user to unprivileged
USER 10001

#move to workdir
WORKDIR ${SONARQUBE_HOME}

#start server
ENTRYPOINT ["run-sonar"]