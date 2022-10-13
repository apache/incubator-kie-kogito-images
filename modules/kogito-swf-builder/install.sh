#!/usr/bin/env bash
set -e

cd "${KOGITO_HOME}"

# Create scaffold project
export PROJECT_GROUP_ID='org.acme'
export PROJECT_ARTIFACT_ID='serverless-workflow-project'
export PROJECT_VERSION='1.0.0-snapshot'
export QUARKUS_EXTENSIONS='quarkus-kubernetes,kogito-quarkus-serverless-workflow,kogito-addons-quarkus-knative-eventing'

"${KOGITO_HOME}"/launch/build-app.sh
