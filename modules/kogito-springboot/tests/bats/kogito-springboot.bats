#!/usr/bin/env bats

# imports
load $BATS_TEST_DIRNAME/../../added/launch/kogito-springboot.sh

@test "check if custom http port is correctly set" {
  export HTTP_PORT="9090"

  configure_springboot_http_port

  result="${KOGITO_SPRINGBOOT_PROPS}"
  expected=" -Dquarkus.http.port=9090"

  echo "Result is ${result} and expected is ${expected}"
    [ "${result}" = "${expected}" ]
}