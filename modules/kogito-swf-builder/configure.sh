#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR=/tmp/artifacts
ADDED_DIR="${SCRIPT_DIR}"/added
LAUNCH_DIR="${KOGITO_HOME}"/launch

cp -v "${ADDED_DIR}"/create-app.sh "${LAUNCH_DIR}"
cp -v "${ADDED_DIR}"/add-extension.sh "${LAUNCH_DIR}"
cp -v "${ADDED_DIR}"/build-app.sh "${LAUNCH_DIR}"

unzip "${SOURCES_DIR}"/kogito-swf-builder-quarkus-app.zip -d "${KOGITO_HOME}"
ls -al "${KOGITO_HOME}"
unzip "${SOURCES_DIR}"/kogito-swf-builder-maven-repo.zip -d "${KOGITO_HOME}"/.m2/repository
ls -al "${KOGITO_HOME}/.m2/repository"

chown -R 1001:0 "${KOGITO_HOME}"
chmod -R ug+rwX "${KOGITO_HOME}"
