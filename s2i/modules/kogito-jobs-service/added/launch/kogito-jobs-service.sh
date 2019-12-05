#!/usr/bin/env bash


function prepareEnv() {
    unset ENABLE_PERSISTENCE
}

function configure() {
    configure_jobs_service
}


function configure_jobs_service() {

    if [ "${ENABLE_PERSISTENCE^^}" == "TRUE" ]; then
        KOGITO_JOBS_PROPS="${KOGITO_JOBS_PROPS} -Dkogito.job-service.persistence=infinispan"
    fi
}

