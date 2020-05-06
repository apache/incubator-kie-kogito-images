#!/usr/bin/env bats

export KOGITO_HOME=/tmp/kogito
mkdir -p ${KOGITO_HOME}/launch
cp $BATS_TEST_DIRNAME/../../../kogito-logging/added/logging.sh ${KOGITO_HOME}/launch/

# imports
load $BATS_TEST_DIRNAME/../../added/launch/kogito-jobs-service.sh

function setup() {
  prepareEnv
  unset KOGITO_JOBS_PROPS
  function log_error { echo "${1}"; }
}

@test "test enable persistence without set infinispan server list" {
    export ENABLE_PERSISTENCE="true"
    run configure_jobs_service
    expected="INFINISPAN_CLIENT_SERVER_LIST env not found, please set it."
    echo "Result is ${output} and expected is ${expected}"
    echo "Status is ${status} and expected status is 1"
    [ "$status" -eq 1 ]
    [ "${output}" = "${expected}" ]
}

@test "check if the backoffRetryMillis is correctly set" {
    export BACKOFF_RETRY="2000"
    configure_jobs_service
    expected=" -Dkogito.jobs-service.backoffRetryMillis=2000"
    echo "Result is ${KOGITO_JOBS_PROPS} and expected is ${expected}"
    [ "${KOGITO_JOBS_PROPS}" = "${expected}" ]
}

@test "check if the maxIntervalLimitToRetryMillis is correctly set" {
    export MAX_INTERVAL_LIMIT_RETRY="8000"
    configure_jobs_service
    expected=" -Dkogito.jobs-service.maxIntervalLimitToRetryMillis=8000"
    echo "Result is ${KOGITO_JOBS_PROPS} and expected is ${expected}"
    [ "${KOGITO_JOBS_PROPS}" = "${expected}" ]
}

@test "check if the maxIntervalLimitToRetryMillis and backoffRetryMillis are correctly set" {
    export MAX_INTERVAL_LIMIT_RETRY="8000"
    export BACKOFF_RETRY="2000"
    configure_jobs_service
    expected=" -Dkogito.jobs-service.backoffRetryMillis=2000 -Dkogito.jobs-service.maxIntervalLimitToRetryMillis=8000"
    echo "Result is ${KOGITO_JOBS_PROPS} and expected is ${expected}"
    [ "${KOGITO_JOBS_PROPS}" = "${expected}" ]
}

@test "check if the persistence is correctly configured with auth" {
    export ENABLE_PERSISTENCE="true"
    export INFINISPAN_CLIENT_SERVER_LIST="localhost:11222"
    configure_jobs_service

    result=${KOGITO_JOBS_PROPS}
    expected=" -Dkogito.jobs-service.persistence=infinispan -Dquarkus.infinispan-client.server-list=localhost:11222"
    echo "Result is ${result} and expected is ${expected}"
    [ "${result}" = "${expected}" ]
}

@test "check if the event is correctly set" {
    export ENABLE_EVENTS="true"
    export KAFKA_BOOTSTRAP_SERVERS="localhost:9999"
    configure_jobs_service

    result="${KOGITO_JOBS_PROPS}"
    expected=" -Dquarkus.profile=events-support -Dmp.messaging.outgoing.kogito-job-service-job-status-events.bootstrap.servers=${KAFKA_BOOTSTRAP_SERVERS} -Devents-support.quarkus.kafka.bootstrap-servers=${KAFKA_BOOTSTRAP_SERVERS}"

    echo "Result is ${result} and expected is ${expected}"
    [ "${result}" = "${expected}" ]
}

@test "enable event without set kafka bootstrap server" {
    export ENABLE_EVENTS="true"
    run configure_jobs_service
    echo "status is ${status}"
    [ "$status" -eq 1 ]
}