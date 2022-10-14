#!/usr/bin/env bash
set -e

script_dir_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
resources_path="$1"
quarkus_create_args=${QUARKUS_CREATE_ARGS}
if [ ! -z "${resources_path}" ]; then
  # quarkus_create_args="${quarkus_create_args} -DnoCode" # Not sure if we want to force the `noCode`
  resources_path="$(realpath "${resources_path}")"
fi

# Call the configure-maven here
source "${script_dir_path}/configure-maven.sh"
configure

cd "${KOGITO_HOME}"

set -x
"${MAVEN_HOME}"/bin/mvn -U -B -s "${MAVEN_SETTINGS_PATH}" \
io.quarkus.platform:quarkus-maven-plugin:"${QUARKUS_VERSION}":create ${quarkus_create_args} \
-DprojectGroupId="${PROJECT_GROUP_ID}" \
-DprojectArtifactId="${PROJECT_ARTIFACT_ID}" \
-DprojectVersionId="${PROJECT_VERSION}" \
-DplatformVersion="${QUARKUS_VERSION}" \
-Dextensions="${QUARKUS_EXTENSIONS}"

cd "${PROJECT_ARTIFACT_ID}"

# Copy resources if exists
if [ ! -z "${resources_path}" ]; then
  if [ -d "${resources_path}" ]; then
    cp -rv "${resources_path}"/* src/main/resources/
  else
    cp -rv "${resources_path}" src/main/resources/
  fi
fi

"${MAVEN_HOME}"/bin/mvn ${MAVEN_ARGS_APPEND} -U -B clean install -DskipTests -s "${MAVEN_SETTINGS_PATH}" -Dquarkus.container-image.build=false
set +x