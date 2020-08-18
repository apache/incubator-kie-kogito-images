#!/bin/bash

function getWorkspacesPath()
{
    local  __imagename=$1
    echo "images_workspace/$__imagename"
}

declare -a IMAGES=("kogito-quarkus-ubi8", 
            "kogito-quarkus-jvm-ubi8",
            "kogito-quarkus-ubi8-s2i",
            "kogito-springboot-ubi8",
            "kogito-springboot-ubi8-s2i",
            "kogito-data-index",
            "kogito-trusty",
            "kogito-explainability",
            "kogito-jobs-service",
            "kogito-management-console")

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
make clone-repos

for IMAGE in "${IMAGES[@]}"
do
  currentFolder=$(pwd)
  
  echo "[INFO] Initializing $IMAGE"
  folder=$(getWorkspacesPath $IMAGE)
  echo "[INFO] Creating folder $folder for image $IMAGE"
  mkdir -p $folder
  rsync -av --progress . $folder --exclude images_workspace

  cd $folder
  
  echo "[INFO] Building image $IMAGE"
  make $IMAGE ignore_test=true cekit_option='--work-dir .'
  
  echo "[INFO] Testing image $IMAGE"
  make $IMAGE ignore_build=true cekit_option='--work-dir .'
  
  cd $currentFolder
done

echo "[INFO] removing $(getWorkspacesPath) folder"
rm -rf $(getWorkspacesPath)

echo "[INFO] removing docker images"
docker rm -f $(docker ps -a -q) || date
docker rmi -f $(docker images -q) || date
