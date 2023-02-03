#!/usr/bin/env bash

source "${KOGITO_HOME}"/launch/logging.sh

function prepareEnv() {
    # keep it on alphabetical order
    unset KOGITO_DATA_INDEX_QUARKUS_PROFILE
}
function configure() {
    configure_data_index_quarkus_profile
}

function configure_data_index_quarkus_profile() {
    local quarkusProfile =${KOGITO_DATA_INDEX_QUARKUS_PROFILE}
    if [ "${quarkusProfile}x" != "x" ]; then
        if [[ "${quarkusProfile}" != "kafka-events-support"  &&  "${quarkusProfile}" != "http-events-support" ]]; then
            log_info "Data Index Quarkus profile ${quarkusProfile} is not valid. Replacing it by the default: `kafka-events-support`"
            quarkusProfile="kafka-events-support"
        fi
    else
        log_info "Applying default quarkus.profile=kafka-events-support"
        quarkusProfile="kafka-events-support"
    fi
    KOGITO_DATA_INDEX_PROPS="${KOGITO_DATA_INDEX_PROPS} -Dquarkus.profile=${quarkusProfile}"
}