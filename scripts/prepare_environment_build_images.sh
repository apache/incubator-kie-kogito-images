#!/bin/bash

curl -Ls https://github.com/kiegroup/kie-cloud-tools/releases/download/1.0-SNAPSHOT/cekit-image-validator-runner.tgz --output cekit-image-validator-runner.tgz
tar -xzvf cekit-image-validator-runner.tgz
chmod +x cekit-image-validator-runner

echo "[INFO] Executing cekit-image-validator-runner"
./cekit-image-validator-runner modules/
./cekit-image-validator-runner image.yaml
./cekit-image-validator-runner kogito-data-index-overrides.yaml
./cekit-image-validator-runner kogito-trusty-overrides.yaml
./cekit-image-validator-runner kogito-explainability-overrides.yaml
./cekit-image-validator-runner kogito-jobs-service-overrides.yaml
./cekit-image-validator-runner kogito-management-console-overrides.yaml
./cekit-image-validator-runner kogito-quarkus-jvm-overrides.yaml
./cekit-image-validator-runner kogito-quarkus-overrides.yaml
./cekit-image-validator-runner kogito-quarkus-s2i-overrides.yaml
./cekit-image-validator-runner kogito-springboot-overrides.yaml
./cekit-image-validator-runner kogito-springboot-s2i-overrides.yaml

echo "[INFO] Make clone-repos"
# make clone-repos 