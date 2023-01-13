#!/usr/bin/env bash
set -e

cd "${PROJECT_ARTIFACT_ID}"
"${MAVEN_HOME}"/bin/mvn ${MAVEN_ARGS_APPEND} -U -B clean compile quarkus:dev -Dquarkus.http.host=0.0.0.0