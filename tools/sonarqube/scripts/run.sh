#!/bin/bash

set -e

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

exec while true; do sleep 10 break; done

#"${SONARQUBE_HOME}/bin/linux-x86-64/sonar.sh"