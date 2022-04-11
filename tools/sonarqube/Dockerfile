FROM sonarqube:8.2-community

MAINTAINER Alef Carvalho <alef.carvalho@inovedados.com.br>

ENV SUMMARY="SonarQube" \
    DESCRIPTION="Deploy the SonarQube on Openshift Container Platform"

LABEL summary="$SUMMARY" \
  description="$DESCRIPTION" \
  io.k8s.description="$DESCRIPTION" \
  io.k8s.display-name="sonarqube" \
  io.openshift.expose-services="9000:http" \
  io.openshift.tags="sonarqube" \
  release="$SONAR_VERSION"

# Define Plug-in Versions
ARG SONAR_ZAP_PLUGIN_VERSION=1.2.0
ENV SONARQUBE_PLUGIN_DIR="$SONARQUBE_HOME/extensions/plugins"

# Switch to root for package installs
USER root

RUN apt-get update && \
    apt-get install -y gettext-base curl zip

# ===============================================================================================
# Mitigation for CVE-2021-44228 and CVE-2021-45046
#   - Set LOG4J_FORMAT_MSG_NO_LOOKUPS=true
#   - Remove JndiLookup.class from the classpath.
#
# References:
#   - https://logging.apache.org/log4j/2.x/security.html
#   - https://github.com/BCDevOps/sonarqube
#
# Search for jars containing JndiLookup.class:
#   - find / -name log4j-core*.jar -exec unzip -vl {} \; 2>/dev/null | grep JndiLookup.class
# -----------------------------------------------------------------------------------------------
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true
RUN find / -name log4j-core*.jar -exec zip -q -d {} org/apache/logging/log4j/core/lookup/JndiLookup.class \; 2>/dev/null
# ===============================================================================================

# ================================================================================================================================================================================
# Bundle Plug-in(s)
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# sonar-zap-plugin - https://github.com/Coveros/zap-sonar-plugin
RUN set -x \
  && cd "$SONARQUBE_PLUGIN_DIR" \
  && curl -o "sonar-zap-plugin-$SONAR_ZAP_PLUGIN_VERSION.jar" -fsSL "https://github.com/Coveros/zap-sonar-plugin/releases/download/sonar-zap-plugin-$SONAR_ZAP_PLUGIN_VERSION/sonar-zap-plugin-$SONAR_ZAP_PLUGIN_VERSION.jar"

# go to sonar workdir
WORKDIR $SONARQUBE_HOME

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UIDs.
RUN chown -R 1001:0 "$SONARQUBE_HOME" \
  && chgrp -R 0 "$SONARQUBE_HOME" \
  && chmod -R g+rwX "$SONARQUBE_HOME" \
  && chmod 775 "$SONARQUBE_HOME/bin/run.sh"

USER 1001
