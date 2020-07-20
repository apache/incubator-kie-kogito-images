#!/usr/bin/env bats

export KOGITO_HOME=/tmp/kogito
export HOME=$KOGITO_HOME
mkdir -p ${KOGITO_HOME}/launch
cp $BATS_TEST_DIRNAME/../../../kogito-logging/added/logging.sh ${KOGITO_HOME}/launch/

# imports
load $BATS_TEST_DIRNAME/../../added/launch/kogito-explainability.sh

teardown() {
    rm -rf ${KOGITO_HOME}
}


@test "http port configuration default value" {
    configure_explainability_http_port
    expected=" -Dquarkus.http.port=8080"
    echo "Result is ${KOGITO_EXPLAINABILITY_PROPS} and expected is ${expected}"
    [ "${KOGITO_EXPLAINABILITY_PROPS}" = "${expected}" ]
}

@test "http port configuration custom value" {
    export HTTP_PORT="9090"
    configure_explainability_http_port
    expected=" -Dquarkus.http.port=9090"
    echo "Result is ${KOGITO_EXPLAINABILITY_PROPS} and expected is ${expected}"
    [ "${KOGITO_EXPLAINABILITY_PROPS}" = "${expected}" ]
}

