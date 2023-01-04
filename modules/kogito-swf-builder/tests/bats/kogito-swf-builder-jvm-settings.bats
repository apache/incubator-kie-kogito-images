#!/usr/bin/env bats

export KOGITO_HOME=/tmp/kogito
export HOME="${KOGITO_HOME}"
export JBOSS_CONTAINER_JAVA_JVM_MODULE=/tmp/container/java/jvm
mkdir -p "${KOGITO_HOME}"/launch
mkdir -p "${JBOSS_CONTAINER_JAVA_JVM_MODULE}"
cp $BATS_TEST_DIRNAME/../../../kogito-logging/added/logging.sh "${KOGITO_HOME}"/launch/
cp -r $BATS_TEST_DIRNAME/../../../kogito-dynamic-resources/added/* "${JBOSS_CONTAINER_JAVA_JVM_MODULE}"/
chmod -R +x "${JBOSS_CONTAINER_JAVA_JVM_MODULE}"
cp $BATS_TEST_DIRNAME/../../added/jvm-settings.sh "${KOGITO_HOME}"/launch/

teardown() {
    rm -rf "${KOGITO_HOME}"
    rm -rf "${JBOSS_CONTAINER_JAVA_JVM_MODULE}"
}

@test "run jvm-settings with no custom conf" {
    expected_status_code=0
    mkdir -p $KOGITO_HOME/my-app

    run ${KOGITO_HOME}/launch/jvm-settings.sh $KOGITO_HOME/my-app

    echo "Output is: ${lines[@]}"
    [[ "${lines[0]}" == *"INFO {jvm-settings} checking if .mvn/jvm.config exists."* ]]
    [[ "${lines[1]}" == *"INFO {jvm-settings} .mvn/jvm.config does not exists, memory will be calculated based on container limits."* ]]
    [[ "${lines[2]}" == *"-XX:+UseParallelOldGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:+ExitOnOutOfMemoryError"* ]]
    [ "$status" = "${expected_status_code}" ]
    echo "Result is [$status] and expected is [${expected_status_code}]" >&2
}

@test "run jvm-settings with no custom conf with no resource path parameter" {
    expected_status_code=0
    mkdir -p $KOGITO_HOME/my-app

    run ${KOGITO_HOME}/launch/jvm-settings.sh

    echo "Output is: ${lines[@]}"
    [[ "${lines[0]}" == *"INFO {jvm-settings} resource directory is empty..."* ]]
    [[ "${lines[1]}" == *"-XX:+UseParallelOldGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:+ExitOnOutOfMemoryError"* ]]
    [ "$status" = "${expected_status_code}" ]
    echo "Result is [$status] and expected is [${expected_status_code}]" >&2
}

@test "run jvm-settings with custom conf" {
    expected_status_code=0
    mkdir -p $KOGITO_HOME/my-app/.mvn
    echo "-Xmx1024m -Xms512m -Xotherthing" > $KOGITO_HOME/my-app/.mvn/jvm.config

    run ${KOGITO_HOME}/launch/jvm-settings.sh $KOGITO_HOME/my-app

    echo "Output is: ${lines[@]}"
    [[ "${lines[0]}" == *"INFO {jvm-settings} checking if .mvn/jvm.config exists."* ]]
    [[ "${lines[1]}" == *"INFO {jvm-settings} .mvn/jvm.config exists."* ]]
    [[ "${lines[2]}" == *"-Xmx1024m -Xms512m -Xotherthing -XX:+UseParallelOldGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:+ExitOnOutOfMemoryError"* ]]
    [ "$status" = "${expected_status_code}" ]
    echo "Result is [$status] and expected is [${expected_status_code}]" >&2
}
