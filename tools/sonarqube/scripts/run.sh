#!/bin/bash

set -e

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

exec ls -la ${SONARQUBE_HOME}/bin

#"${SONARQUBE_HOME}/bin/linux-x86-64/sonar.sh"