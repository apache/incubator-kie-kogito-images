#!/usr/bin/env bats

# import
load $BATS_TEST_DIRNAME/../../added/launch/kogito-jobs-service.sh


@test "check if the persistence is correctly configured" {
    export ENABLE_PERSISTENCE="true"
    configure_jobs_service
    expected=" -Dkogito.job-service.persistence=infinispan"
    echo "Result is ${KOGITO_JOBS_PROPS} and expected is ${expected}"
    [ "${KOGITO_JOBS_PROPS}" = "${expected}" ]
}

