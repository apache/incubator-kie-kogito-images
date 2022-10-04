#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADDED_DIR="${SCRIPT_DIR}"/added

cp -v "${ADDED_DIR}"/build-app.sh "${KOGITO_HOME}"/launch

chown -R 1001:0 "${KOGITO_HOME}"
chmod -R ug+rwX "${KOGITO_HOME}"
