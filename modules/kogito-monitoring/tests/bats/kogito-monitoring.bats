#!/usr/bin/env bats

export KOGITO_HOME=$BATS_TMPDIR/kogito_home
export MOCK_RESPONSE=""
mkdir -p $KOGITO_HOME/launch

cp $BATS_TEST_DIRNAME/../../../kogito-logging/added/logging.sh $KOGITO_HOME/launch/
cp $BATS_TEST_DIRNAME/../../../kogito-kubernetes-client/added/kogito-kubernetes-client.sh $KOGITO_HOME/launch/

# imports
source $BATS_TEST_DIRNAME/../../added/kogito-monitoring.sh

unset -f list_or_get_k8s_resource
unset -f patch_json_k8s_resource
unset -f is_running_on_kubernetes

function is_running_on_kubernetes() {
    # yes, we are :)
    log_info "Yes, we are in kubernetes"
    return 0
}

function patch_json_k8s_resource() {
    local api="${1}"
    local resource="${2}"
    local body="${3}"

    log_info "Calling k8s api '${api}', resource '${resource}'"
    echo "${body}200"
}

function list_or_get_k8s_resource() {
    local response=$(cat $BATS_TEST_DIRNAME/mocks/$MOCK_RESPONSE)
    response="${response}200"
    echo "${response}"
}

setup() {
    export HOME=$KOGITO_HOME
    mkdir -p ${KOGITO_HOME}
    mkdir -p $KOGITO_HOME/bin
    mkdir -p $KOGITO_HOME/data/dashboards/
    mkdir -p $KOGITO_HOME/podinfo
    echo "exampleapp-cm" > $KOGITO_HOME/podinfo/protobufcm
}

teardown() {
    rm -rf ${KOGITO_HOME}
    rm -rf /tmp/src
    rm -rf $KOGITO_HOME/bin/*
}

@test "There's some dashboard files in the target directory" {
    mkdir -p /tmp/src/target/generated-resources/kogito/dashboards 
    touch /tmp/src/target/generated-resources/kogito/dashboards/{test-dashboard.json,my-dashboard.json}

    run copy_monitoring_files

    echo "result= ${lines[@]}"

    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INFO ---> [monitoring] Copying monitoring files..." ]
    [ "${lines[1]}" = "'/tmp/src/target/generated-resources/kogito/dashboards/my-dashboard.json' -> '${KOGITO_HOME}/bin/my-dashboard.json'" ]
    [ "${lines[2]}" = "'/tmp/src/target/generated-resources/kogito/dashboards/test-dashboard.json' -> '${KOGITO_HOME}/bin/test-dashboard.json'" ]
    [ "${lines[3]}" = "INFO ---> [monitoring] Moving monitoring files to final directory" ]
    [ "${lines[4]}" = "'${KOGITO_HOME}/bin/my-dashboard.json' -> '${KOGITO_HOME}/data/dashboards/my-dashboard.json'" ]
    [ "${lines[5]}" = "'${KOGITO_HOME}/bin/test-dashboard.json' -> '${KOGITO_HOME}/data/dashboards/test-dashboard.json'" ]
    [ "${lines[6]}" = "INFO ---> [monitoring] generating md5 for monitoring files" ]
    [ "${lines[7]}" = "INFO ----> [monitoring] Generated checksum for ${KOGITO_HOME}/data/dashboards/my-dashboard.json with the name: ${KOGITO_HOME}/data/dashboards/my-dashboard-md5.txt" ]
    [ "${lines[8]}" = "INFO ----> [monitoring] Generated checksum for ${KOGITO_HOME}/data/dashboards/test-dashboard.json with the name: ${KOGITO_HOME}/data/dashboards/test-dashboard-md5.txt" ]
}

@test "There are no monitoring files" {
    KOGITO_HOME=/tmp/kogito

    run copy_monitoring_files

    echo "result= ${lines[@]}"

    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INFO ---> [monitoring] Copying monitoring files..." ]
    [ "${lines[1]}" = "INFO ---> [monitoring] Skip copying files, monitoring dashboards directory does not exist..." ]
}

@test "There's some dashboard files in the bin directory" {
    touch $KOGITO_HOME/bin/my-dashboard.json

    run move_monitoring_files

    echo "result= ${lines[@]}"

    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INFO ---> [monitoring] Moving monitoring files to final directory" ]
    [ "${lines[1]}" = "'${KOGITO_HOME}/bin/my-dashboard.json' -> '${KOGITO_HOME}/data/dashboards/my-dashboard.json'" ]
    [ "${lines[2]}" = "INFO ---> [monitoring] generating md5 for monitoring files" ]
    [ "${lines[3]}" = "INFO ----> [monitoring] Generated checksum for ${KOGITO_HOME}/data/dashboards/my-dashboard.json with the name: ${KOGITO_HOME}/data/dashboards/my-dashboard-md5.txt" ]
}

@test "There's no dashboard files in the bin directory" {
    run move_monitoring_files

    echo "result= ${lines[@]}"

    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INFO ---> [monitoring] Moving monitoring files to final directory" ]
    [ "${lines[1]}" = "INFO ---> [monitoring] Skip copying files, ${KOGITO_HOME}/bin directory does not have dashboard files!" ]
}

@test "MD5 correctly generated for dashboard files" {
    touch $KOGITO_HOME/data/dashboards/my-dashboard.json

    run generate_md5_monitoring_files
    echo "result= ${lines[@]}"

    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "INFO ---> [monitoring] generating md5 for monitoring files" ]
    [ "${lines[1]}" = "INFO ----> [monitoring] Generated checksum for ${KOGITO_HOME}/data/dashboards/my-dashboard.json with the name: ${KOGITO_HOME}/data/dashboards/my-dashboard-md5.txt" ]
    [ -e $KOGITO_HOME/data/dashboards/my-dashboard-md5.txt ]
    # if md5 isn't generated, grep will fail to find the given string
    grep -q "d41d8cd98f00b204e9800998ecf8427e" $KOGITO_HOME/data/dashboards/my-dashboard-md5.txt
}

@test "MD5 not generated for my-dashboard.json1" {
    touch $KOGITO_HOME/data/dashboards/my-dashboard.json1

    run generate_md5_monitoring_files
    echo "result= ${lines[@]}"

    [ "$status" -eq 0 ]
    [ ! -e $KOGITO_HOME/data/dashboards/my-dashboard-md5.txt ]
}

@test "MD5 not generated for a dashboard that does not contain the word 'dashboard' in the filename" {
    touch $KOGITO_HOME/data/dashboards/my.json

    run generate_md5_monitoring_files
    echo "result= ${lines[@]}"

    [ "$status" -eq 0 ]
    [ ! -e $KOGITO_HOME/data/dashboards/my-md5.txt ]
}

@test "Patch a configMap when we have empty annotations and data" {
    MOCK_RESPONSE="config_map_no_annotations.json"
    cp -v $BATS_TEST_DIRNAME/mocks/operational-dashboard-hello.json $KOGITO_HOME/data/dashboards/
    cp -v $BATS_TEST_DIRNAME/mocks/domain-dashboard-LoanEligibility.json $KOGITO_HOME/data/dashboards/
    generate_md5_monitoring_files

    local expected=$(cat $BATS_TEST_DIRNAME/expected/patch_dashboards.json)

    run update_monitoring_configmap

    echo "result= ${lines[@]}"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "INFO ---> [monitoring] About to patch configMap exampleapp-cm" ]
    [ "${lines[2]}" = "Body: ${expected}" ]
}

@test "Patch a configMap with empty data" {
    MOCK_RESPONSE="config_map.json" # we have annotations, but no files in the file system
    
    local expected=$(cat $BATS_TEST_DIRNAME/expected/patch_empty_data.json)

    run update_monitoring_configmap
    
    echo "result= ${lines[@]}"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "INFO ---> [monitoring] About to patch configMap exampleapp-cm" ]
    [ "${lines[2]}" = "Body: ${expected}" ]
}

@test "Patch with an empty annotations configmap with files in disk" {
    MOCK_RESPONSE="config_map_empty_annotations.json" # we have empty annotations and files in disk
    
    cp -v $BATS_TEST_DIRNAME/mocks/operational-dashboard-hello.json $KOGITO_HOME/data/dashboards/
    cp -v $BATS_TEST_DIRNAME/mocks/domain-dashboard-LoanEligibility.json $KOGITO_HOME/data/dashboards/
    generate_md5_monitoring_files

    local expected=$(cat $BATS_TEST_DIRNAME/expected/patch_dashboards.json)

    run update_monitoring_configmap
    
    echo "result= ${lines[@]}"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "INFO ---> [monitoring] About to patch configMap exampleapp-cm" ]
    [ "${lines[2]}" = "Body: ${expected}" ]
}