#!/usr/bin/env bash
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

#
# Clone the kogito-examples and edit the rules-quarkus-helloworld and dmn-quarkus-example for testing purposes
# if image name is supporting services, don't build it
IMAGE_NAME="$2"
KOGITO_EXAMPLES_REPO_NAME='incubator-kie-kogito-examples'
KOGITO_EXAMPLES_FOLDER_NAME='kogito-examples' # many tests rely on location /tmp/kogito-examples

if [ -n "${IMAGE_NAME}" ]; then
    if python ../../scripts/list-images.py -is ${IMAGE_NAME}; then
        echo "Target image is supporting services, skipping examples build"
        exit 0
    fi
fi

set -e
realPath="realpath"
if [[ $OSTYPE == 'darwin'* ]]; then
  # If you are on MacOS, use "brew install coreutils"
  realPath="grealpath"
fi
base_dir=`dirname $(${realPath} -s $0)`
echo $base_dir
. ${base_dir}/../../scripts/setup-maven.sh "$(mktemp)"

CONTAINER_ENGINE=${CONTAINER_ENGINE:-"docker"}
MAVEN_QUARKUS_NATIVE_CONTAINER_BUILD_ARGS=${MAVEN_QUARKUS_NATIVE_CONTAINER_BUILD_ARGS:-"-Dquarkus.native.container-build=true -Dquarkus.native.container-runtime=${CONTAINER_ENGINE}"}

NATIVE_BUILD=$1
if [ -z $NATIVE_BUILD ]; then
    NATIVE_BUILD=true
fi

set -e

# Clone examples
KOGITO_EXAMPLES_DIR=/tmp/${KOGITO_EXAMPLES_FOLDER_NAME}
rm -rf ${KOGITO_EXAMPLES_DIR}
git clone https://github.com/apache/${KOGITO_EXAMPLES_REPO_NAME}.git ${KOGITO_EXAMPLES_DIR}
cd ${KOGITO_EXAMPLES_DIR}/
git fetch origin
git fetch origin --tags
git switch nightly-main

# make a new copy of rules-quarkus-helloworld for native tests
cp -rv  ${KOGITO_EXAMPLES_DIR}/kogito-quarkus-examples/rules-quarkus-helloworld/ ${KOGITO_EXAMPLES_DIR}/kogito-quarkus-examples/rules-quarkus-helloworld-native/

set -x

# generating the app binaries to test the binary build
mvn -f kogito-quarkus-examples/rules-quarkus-helloworld clean package ${MAVEN_OPTIONS}
mvn -f kogito-springboot-examples/process-springboot-example clean package ${MAVEN_OPTIONS}

if [ "$NATIVE_BUILD" = 'true' ]; then
    mvn -f kogito-quarkus-examples/rules-quarkus-helloworld-native -Dnative clean package ${MAVEN_OPTIONS} ${MAVEN_QUARKUS_NATIVE_CONTAINER_BUILD_ARGS}
    ls -lah ${KOGITO_EXAMPLES_DIR}/kogito-quarkus-examples/rules-quarkus-helloworld-native/target/
fi

# preparing directory to run kogito maven archetypes tests
mkdir -pv ${KOGITO_EXAMPLES_DIR}/dmn-example
cp ${KOGITO_EXAMPLES_DIR}/kogito-quarkus-examples/dmn-quarkus-example/src/main/resources/* ${KOGITO_EXAMPLES_DIR}/dmn-example/

# by adding the application.properties file telling app to start on
# port 10000, the purpose of this tests is make sure that the images
# will ensure the use of the port 8080.

cp ${base_dir}/application.properties ${KOGITO_EXAMPLES_DIR}/kogito-quarkus-examples/rules-quarkus-helloworld/src/main/resources/META-INF/
(echo ""; echo "server.port=10000") >> ${KOGITO_EXAMPLES_DIR}/kogito-springboot-examples/process-springboot-example/src/main/resources/application.properties

set +x

git config commit.gpgsign false
git add --all  :/
git commit -am "test"