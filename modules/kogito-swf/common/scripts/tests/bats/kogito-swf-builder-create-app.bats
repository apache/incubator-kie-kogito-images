#!/usr/bin/env bats
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

setup_file() {
    export KOGITO_HOME=/tmp/kogito
    export HOME="${KOGITO_HOME}"
    export SONATAFLOW_DEPLOYMENT_WEBAPP_VERSION="0.32.0"

    export PROJECT_ARTIFACT_ID='serverless-workflow-project'
    export PROJECT_DIR="${KOGITO_HOME}/${PROJECT_ARTIFACT_ID}"
    export PROJECT_POM="${PROJECT_DIR}"/pom.xml
    export SONATAFLOW_DEPLOYMENT_WEBAPP_DATA_JSON_FILENAME="sonataflow-deployment-webapp-data.json"
    export SONATAFLOW_DEPLOYMENT_WEBAPP_DATA_JSON="${PROJECT_DIR}/src/main/resources/META-INF/resources/${SONATAFLOW_DEPLOYMENT_WEBAPP_DATA_JSON_FILENAME}"

    rm -rf "${KOGITO_HOME}"
    mkdir -p ${HOME}/.m2/
    cp $BATS_TEST_DIRNAME/../../../../../kogito-maven/common/maven/settings.xml ${HOME}/.m2/
    export MAVEN_SETTINGS_PATH="${HOME}/.m2/settings.xml"
    export JBOSS_CONTAINER_JAVA_JVM_MODULE=${KOGITO_HOME}/launch

    mkdir -p "${KOGITO_HOME}"/launch

    cp $BATS_TEST_DIRNAME/../../added/configure-jvm-mvn.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../../../../kogito-maven/common/added/configure-maven.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../../../../kogito-dynamic-resources/added/debug-options "${KOGITO_HOME}"/launch/
    chmod +x "${KOGITO_HOME}"/launch/debug-options 
    cp $BATS_TEST_DIRNAME/../../../../../kogito-dynamic-resources/added/java-default-options "${KOGITO_HOME}"/launch/
    chmod +x "${KOGITO_HOME}"/launch/java-default-options 
    cp $BATS_TEST_DIRNAME/../../../../../kogito-dynamic-resources/added/container-limits "${KOGITO_HOME}"/launch/
    chmod +x "${KOGITO_HOME}"/launch/container-limits
    cp $BATS_TEST_DIRNAME/../../added/jvm-settings.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../../../../kogito-logging/added/logging.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../added/create-app.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../added/build-app.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../added/add-sonataflow-deployment-webapp.sh "${KOGITO_HOME}"/launch/

    source ${KOGITO_HOME}/launch/configure-maven.sh

    cd "${KOGITO_HOME}" 
    source ${KOGITO_HOME}/launch/create-app.sh

    source ${KOGITO_HOME}/launch/build-app.sh
}

teardown_file() {
    rm -rf "${KOGITO_HOME}"
}

@test "Verify the project contains the pom.xml" {
    [[ -f $PROJECT_POM ]]
}

@test "Check the value of the node sonataFlowDeploymentWebapp.version" {
  result=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='properties']/*[local-name()='sonataFlowDeploymentWebapp.version']/text()" $PROJECT_POM)
  [ "$result" == $SONATAFLOW_DEPLOYMENT_WEBAPP_VERSION ]
}

@test "Check node 'dependencies' has a node 'dependency' with 'artifactId' node with value 'sonataflow-deployment-webapp'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='dependencies']/*[local-name()='dependency'][*[local-name()='artifactId']='sonataflow-deployment-webapp'])" $PROJECT_POM)
  [ "$result" -eq 1 ]
}

@test "Check node 'dependencyManagement' doesn't have a node 'dependency' with 'artifactId' node with value 'sonataflow-deployment-webapp'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='dependencyManagement']/*[local-name()='dependencies']/*[local-name()='dependency'][*[local-name()='artifactId']='sonataflow-deployment-webapp'])" $PROJECT_POM)
  [ "$result" -eq 0 ]
}

@test "Check node 'plugins' has a 'plugin' with execution id 'unpack-sonataflow-deployment-webapp'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='build']/*[local-name()='plugins']/*[local-name()='plugin']/*[local-name()='executions']/*[local-name()='execution']/*[local-name()='id'][text()='unpack-sonataflow-deployment-webapp'])" $PROJECT_POM)
  [ "$result" -eq 1 ]
}

@test "Check node 'plugins' has a 'plugin' with execution id 'copy-sonataflow-deployment-webapp-resources'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='build']/*[local-name()='plugins']/*[local-name()='plugin']/*[local-name()='executions']/*[local-name()='execution']/*[local-name()='id'][text()='copy-sonataflow-deployment-webapp-resources'])" $PROJECT_POM)
  [ "$result" -eq 1 ]
}
@test "Verify the project contains the ${SONATAFLOW_DEPLOYMENT_WEBAPP_DATA_JSON_FILENAME}" {
    [[ -f $SONATAFLOW_DEPLOYMENT_WEBAPP_DATA_JSON ]]
}

@test "Check property showDisclaimer in ${SONATAFLOW_DEPLOYMENT_WEBAPP_DATA_JSON_FILENAME}" {
    result=$(jq -r ".showDisclaimer" $SONATAFLOW_DEPLOYMENT_WEBAPP_DATA_JSON)
    [ "$result" == "false" ]
}

