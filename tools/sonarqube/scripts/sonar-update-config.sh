#!/bin/sh

echo "UPDATING SONAR CONFIG FROM ENVIRONMENT VARIABLES"

# update configuration file
cd ${SONARQUBE_HOME}/conf && envsubst < sonar.properties > sonar.properties
