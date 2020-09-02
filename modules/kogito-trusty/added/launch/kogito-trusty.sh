#!/usr/bin/env bash


function prepareEnv() {
    # keep it on alphabetical order
    unset EXPLAINABILITY_ENABLED
    unset HTTP_PORT
}

function configure() {
    configure_trusty_http_port
    enable_explainability
}

function configure_trusty_http_port {
    local httpPort=${HTTP_PORT:-8080}
    KOGITO_TRUSTY_PROPS="${KOGITO_TRUSTY_PROPS} -Dquarkus.http.port=${httpPort}"
}

function enable_explainability {
    local explainabilityEnabled=${EXPLAINABILITY_ENABLED:"true"}
    if [ "${explainabilityEnabled^^}" = "TRUE" ] ; then 
          explainabilityEnabled="true"
    fi
    KOGITO_TRUSTY_PROPS="${KOGITO_TRUSTY_PROPS} -Dtrusty.explainability.enabled=${explainabilityEnabled}"
}
