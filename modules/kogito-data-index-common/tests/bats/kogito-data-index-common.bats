#!/usr/bin/env bats

export KOGITO_HOME=/tmp/kogito
export HOME="${KOGITO_HOME}"
mkdir -p "${KOGITO_HOME}"/launch
cp $BATS_TEST_DIRNAME/../../../kogito-logging/added/logging.sh "${KOGITO_HOME}"/launch/

# imports
load $BATS_TEST_DIRNAME/../../added/launch/kogito-data-index-common.sh


teardown() {
    rm -rf "${KOGITO_HOME}"
}

@test "check if the quarkus profile correctly set on data index" {
    configure_data_index_events

    result="${KOGITO_DATA_INDEX_PROPS}"
    expected=" -Dquarkus.profile=kafka-events-support"

    echo "Result is ${result} and expected is ${expected}"
    [ "${result}" = "${expected}" ]
}

