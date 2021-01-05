#!/usr/bin/env bash

#import
source "${KOGITO_HOME}"/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    SHOW_JVM_SETTINGS="-XshowSettings:properties"
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
    log_info "JVM settings debug is enabled."
    printenv
fi

# Configuration scripts
# Any configuration script that needs to run on image startup must be added here.
CONFIGURE_SCRIPTS=(
  "${KOGITO_HOME}"/launch/kogito-trusty.sh
)
source "${KOGITO_HOME}"/launch/configure.sh
#############################################

# shellcheck disable=SC2086
exec java ${SHOW_JVM_SETTINGS} ${JAVA_OPTIONS} ${KOGITO_TRUSTY_PROPS} \
        -Djava.library.path="${KOGITO_HOME}"/lib \
        -Dquarkus.http.host=0.0.0.0 \
        -Dquarkus.http.port=8080 \
        -jar "${KOGITO_HOME}"/bin/kogito-trusty-infinispan.jar