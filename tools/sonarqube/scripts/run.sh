#!/bin/sh

# update configuration file
cd /opt/sonarqube/conf && envsubst < sonar.properties > sonar.properties

# start services
supervisord -n
