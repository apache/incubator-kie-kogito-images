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
    export HOME="${KOGITO_HOME}"
    mkdir -p "${KOGITO_HOME}"/launch
    mock_bin kn-workflow
    mkdir -p "${KOGITO_HOME}"/serverless-workflow-project/src/main/resources/schemas

    touch "${KOGITO_HOME}"/launch/configure-jvm-mvn.sh
    cp $BATS_TEST_DIRNAME/../../added/generate-manifests.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../../kogito-logging/added/logging.sh "${KOGITO_HOME}"/launch/
    cp $BATS_TEST_DIRNAME/../../../kogito-swf/common/scripts/added/build-app.sh "${KOGITO_HOME}"/launch/
}

teardown() {
    rm -rf "${KOGITO_HOME}"
    rm -rf /tmp/resources
}

@test "verify generate manifest is working" {
    TEMPD=$(mktemp -d)
    cp -r $BATS_TEST_DIRNAME/../../../../tests/shell/kogito-swf-builder/resources/greet-with-inputschema/* ${TEMPD}

    # opt-in to generate-manifests
    export GEN_MANIFESTS=true
    # We don't care about the errors to try to execute and build the program, just the copy matters
    source ${KOGITO_HOME}/launch/build-app.sh ${TEMPD} || true

    # this tests the call to kn-workflow actually happend
    [ -f "${KOGITO_HOME}"/bin/kn-workflow_invocation.txt ] 
}

@test "verify generate manifest is an opt-in" {
    TEMPD=$(mktemp -d)
    cp -r $BATS_TEST_DIRNAME/../../../../tests/shell/kogito-swf-builder/resources/greet-with-inputschema/* ${TEMPD}

    # opt-out to generate-manifests
    export GEN_MANIFESTS=false
    # We don't care about the errors to try to execute and build the program, just the copy matters
    source ${KOGITO_HOME}/launch/build-app.sh ${TEMPD} || true

    # this tests that the call to kn-workflow didn't happend
    [ ! -f "${KOGITO_HOME}"/bin/kn-workflow_invocation.txt ] 
}

mock_bin() {
    mkdir -p "${KOGITO_HOME}"/bin
    PATH+=":${KOGITO_HOME}/bin/"
    cat << EOF > "${KOGITO_HOME}"/bin/$1
    echo $1 "$@" > $"${KOGITO_HOME}"/bin/$1_invocation.txt
EOF
    chmod +x "${KOGITO_HOME}"/bin/$1
}

