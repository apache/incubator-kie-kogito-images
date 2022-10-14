#!/usr/bin/env bash
set -e

script_dir_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cd "${KOGITO_HOME}"

# Call the configure-maven here
source "${KOGITO_HOME}"/launch/configure-maven.sh
configure

set -x
"${MAVEN_HOME}"/bin/mvn -U -B -s "${MAVEN_SETTINGS_PATH}" \
io.quarkus.platform:quarkus-maven-plugin:"${QUARKUS_VERSION}":create ${QUARKUS_CREATE_ARGS} \
-DprojectGroupId="${PROJECT_GROUP_ID}" \
-DprojectArtifactId="${PROJECT_ARTIFACT_ID}" \
-DprojectVersionId="${PROJECT_VERSION}" \
-DplatformVersion="${QUARKUS_VERSION}" \
-Dextensions="${quarkus-kubernetes,kogito-quarkus-serverless-workflow,kogito-addons-quarkus-knative-eventing}"

cd "${PROJECT_ARTIFACT_ID}"

"${MAVEN_HOME}"/bin/mvn ${MAVEN_ARGS_APPEND} -U -B clean install -DskipTests -s "${MAVEN_SETTINGS_PATH}" -Dquarkus.container-image.build=false
set +x