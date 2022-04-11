#!/usr/bin/env bash

echo "UPDATING SONAR CONFIG FROM ENVIRONMENT VARIABLES"

# update configuration file
cd ${SONARQUBE_HOME}/conf && envsubst < sonar.properties > sonar.properties

# run sonar
cd ${SONARQUBE_HOME} && exec java -jar lib/sonar-application-"${SONAR_VERSION}".jar -Dsonar.log.console=true "$@"
