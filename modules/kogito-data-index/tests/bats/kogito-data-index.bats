#!/usr/bin/env bats

# imports
load $BATS_TEST_DIRNAME/../../added/launch/kogito-data-index.sh

setup() {
    prepareEnv
}

@test "when kogito-data-index port provided" {
    export KOGITO_DATA_INDEX_HTTP_PORT="9090"
    local expected=" -Dquarkus.http.port=${KOGITO_DATA_INDEX_HTTP_PORT}"
    configure_data_index_http_port
    echo "Result is ${KOGITO_DATA_INDEX_PROPS} and expected is ${expected}" >&2
    [ "${expected}" = "${KOGITO_DATA_INDEX_PROPS}" ]
}

@test "when kogito-data-index port not provided" {
    local expected=" -Dquarkus.http.port=8080"
    configure_data_index_http_port
    echo "Result is ${KOGITO_DATA_INDEX_PROPS} and expected is ${expected}" >&2
    [ "${expected}" = "${KOGITO_DATA_INDEX_PROPS}" ]
}