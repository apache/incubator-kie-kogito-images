#!/usr/bin/env bash
#
# S2I run script for the 'kogito-runtime-jvm' images.
# The run script executes the server that runs your application.
#
# For more information see the documentation:
#	https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md
#
# Image help.
if [[ "$1" == "-h" ]]; then
    exec /usr/local/s2i/usage
    exit 0
fi

# Configuration scripts
# Any configuration script that needs to run on image startup must be added here.
CONFIGURE_SCRIPTS=(

)
source ${S2I_MODULE_LOCATION}/s2i-core
source "${KOGITO_HOME}"/launch/configure.sh

runtime_type=$(get_runtime_type)

#############################################

# shellcheck disable=SC2086
if [ "${runtime_type}" == "quarkus" ]; then
    exec java ${JAVA_OPTIONS}  ${KOGITO_QUARKUS_JVM_PROPS} \
        -Dquarkus.http.host=0.0.0.0 \
        -Dquarkus.http.port=8080 \
        -jar "${KOGITO_HOME}"/bin/*runner.jar
else
    exec java ${JAVA_OPTIONS} ${KOGITO_SPRINGBOOT_PROPS} -Dserver.address=0.0.0.0 -Dserver.port=8080 -jar "${KOGITO_HOME}"/bin/*.jar
fi