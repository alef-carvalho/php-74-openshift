#!/bin/bash

echo "Loading configuration"
source /etc/profile

echo "Starting supervisor" 
supervisord --nodaemon --configuration /etc/supervisord.conf