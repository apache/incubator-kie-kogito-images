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

setup() {
    export KOGITO_HOME=/tmp/kogito
    export SONATA_FLOW_DEPLOYMENT_WEBAPP_VERSION="0.32.0"
    mkdir "${KOGITO_HOME}"
    cp $BATS_TEST_DIRNAME/mocks/pom.xml "${KOGITO_HOME}"/

    (cd $KOGITO_HOME && source $BATS_TEST_DIRNAME/../../added/add-sonataflow-deployment-webapp.sh)
}

teardown() {
    rm -rf "${KOGITO_HOME}"
}

@test "Verify the pom.xml has been copied from the mocks" {
    [[ -f "${KOGITO_HOME}"/pom.xml ]]
}

@test "Check the value of the node sonataFlowDeploymentWebapp.version" {
  result=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='properties']/*[local-name()='sonataFlowDeploymentWebapp.version']/text()" "${KOGITO_HOME}"/pom.xml)
  [ "$result" == $SONATA_FLOW_DEPLOYMENT_WEBAPP_VERSION ]
}

@test "Check node 'dependencies' has a node 'dependency' with 'artifactId' node with value 'sonataflow-deployment-webapp'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='dependencies']/*[local-name()='dependency'][*[local-name()='artifactId']='sonataflow-deployment-webapp'])" "${KOGITO_HOME}"/pom.xml)
  [ "$result" -eq 1 ]
}

@test "Check node 'dependencyManagement' doesn't have a node 'dependency' with 'artifactId' node with value 'sonataflow-deployment-webapp'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='dependencyManagement']/*[local-name()='dependencies']/*[local-name()='dependency'][*[local-name()='artifactId']='sonataflow-deployment-webapp'])" "${KOGITO_HOME}"/pom.xml)
  [ "$result" -eq 0 ]
}

@test "Check node 'plugins' has a 'plugin' with execution id 'unpack-sonataflow-deployment-webapp'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='build']/*[local-name()='plugins']/*[local-name()='plugin']/*[local-name()='executions']/*[local-name()='execution']/*[local-name()='id'][text()='unpack-sonataflow-deployment-webapp'])" "${KOGITO_HOME}"/pom.xml)
  [ "$result" -eq 1 ]
}

@test "Check node 'plugins' has a 'plugin' with execution id 'copy-sonataflow-deployment-webapp-resources'" {
  result=$(xmllint --xpath "count(/*[local-name()='project']/*[local-name()='build']/*[local-name()='plugins']/*[local-name()='plugin']/*[local-name()='executions']/*[local-name()='execution']/*[local-name()='id'][text()='copy-sonataflow-deployment-webapp-resources'])" "${KOGITO_HOME}"/pom.xml)
  [ "$result" -eq 1 ]
}
