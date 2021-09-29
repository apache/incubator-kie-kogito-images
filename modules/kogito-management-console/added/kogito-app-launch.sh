#!/usr/bin/env bash

#import
source "${KOGITO_HOME}"/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    SHOW_JVM_SETTINGS="-XshowSettings:properties"
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
    log_info "JVM settings debug is enabled."
fi


# Configuration scripts
# Any configuration script that needs to run on image startup must be added here.
CONFIGURE_SCRIPTS=(
  "${KOGITO_HOME}"/launch/kogito-management-console.sh
  "${KOGITO_HOME}"/launch/configure-custom-truststore.sh
)
source "${KOGITO_HOME}"/launch/configure.sh
#############################################

JAVA_OPTS="$(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/java-default-options) $(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/debug-options)"

# shellcheck disable=SC2086
exec java ${SHOW_JVM_SETTINGS} ${JAVA_OPTS} ${JAVA_OPTIONS} ${KOGITO_MANAGEMENT_CONSOLE_PROPS} ${CUSTOM_TRUSTSTORE_ARGS} \
        -Dquarkus.http.host=0.0.0.0 \
        -Dquarkus.http.port=8080 \
        -jar "${KOGITO_HOME}"/bin/management-console-runner.jar