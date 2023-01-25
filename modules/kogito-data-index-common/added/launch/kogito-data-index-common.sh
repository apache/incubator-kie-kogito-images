#!/usr/bin/env bash

source "${KOGITO_HOME}"/launch/logging.sh

function configure() {
    configure_data_index_events
}

function configure_data_index_events() {
    KOGITO_DATA_INDEX_PROPS="${KOGITO_DATA_INDEX_PROPS} -Dquarkus.profile=kafka-events-support"
}