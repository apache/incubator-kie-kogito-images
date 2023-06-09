#!/usr/bin/env bash

# identify the caller, if it is called by run-add-devmode.sh or by the build-app.sh, the jvm
# configuration will me ignored.
ignore_jvm_settings=${2:-false}

script_dir_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
extensions="$1"

source "${script_dir_path}"/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    export MAVEN_ARGS_APPEND="${MAVEN_ARGS_APPEND} -X --batch-mode"
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
    printenv
fi

if [ "${ignore_jvm_settings}" = "false" ]; then
    source "${script_dir_path}"/configure-jvm-mvn.sh
fi

"${MAVEN_HOME}"/bin/mvn -B ${MAVEN_ARGS_APPEND} \
    -nsu \
    -s "${MAVEN_SETTINGS_PATH}" \
    -DplatformVersion="${QUARKUS_PLATFORM_VERSION}" \
    -Dextensions="${extensions}" \
    ${QUARKUS_ADD_EXTENSION_ARGS} \
    io.quarkus.platform:quarkus-maven-plugin:"${QUARKUS_PLATFORM_VERSION}":add-extension
