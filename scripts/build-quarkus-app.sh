#!/usr/bin/env bash
# Parameters:
#   1 - image name - can't  be empty.
#   2 - git target branch - defaults to main
#   3 - git target uri - defaults to https://github.com/kiegroup/kogito-apps.git

# fast fail
set -e
set -o pipefail

# Read entries before sourcing
image_name="${1}"
quarkus_platform_version="${2}"

if [ -z ${quarkus_platform_version} ]; then
    echo "Please provide the quarkus version"
    exit 1
fi

case ${image_name} in
    "kogito-swf-builder")        ;;
    *)
        echo "${image_name} is not a quarkus app image, exiting..."
        exit 0
        ;;
esac


script_dir_path=$(cd `dirname "${BASH_SOURCE[0]}"`; pwd -P)

target_tmp_dir="/tmp/build/kogito-swf-builder"
build_target_dir="/tmp/kogito-swf-builder"
mvn_local_repo="/tmp/temp_maven/kogito-swf-builder"

rm -rf ${target_tmp_dir} && mkdir -p ${target_tmp_dir}
rm -rf ${build_target_dir} && mkdir -p ${build_target_dir}
if [ "${CI}" = "true" ]; then
    # On CI we want to make sure we remove all artifacts from maven repo
    rm -rf ${mvn_local_repo}
fi
mkdir -p ${mvn_local_repo}

. ${script_dir_path}/setup-maven.sh "${build_target_dir}"/settings.xml

set -x
echo "Create quarkus project to path ${build_target_dir}"
cd ${build_target_dir}
mvn ${MAVEN_OPTIONS} \
    -Dmaven.repo.local=${mvn_local_repo} \
    -DprojectGroupId="org.acme" \
    -DprojectArtifactId="serverless-workflow-project" \
    -DprojectVersionId="1.0.0-SNAPSHOT" \
    -DplatformVersion="${quarkus_platform_version}" \
    -Dextensions="quarkus-kubernetes,kogito-quarkus-serverless-workflow,kogito-addons-quarkus-knative-eventing,smallrye-health" \
    io.quarkus.platform:quarkus-maven-plugin:"${quarkus_platform_version}":create

if [ ! -z ${kogito_version} ]; then
    echo "Replacing Kogito Platform BOM with version ${kogito_version}"

    # [ ]* -> is a regexp pattern to match any number of spaces
    pattern_1="[ ]*<groupId>.*<\/groupId>"
    pattern_2="[ ]*<artifactId>quarkus-kogito-bom<\/artifactId>\n"
    pattern_3="[ ]*<version>.*<\/version>\n"
    complete_pattern="$pattern_1\n$pattern_2$pattern_3"

    replace_1="        <groupId>org.kie.kogito<\/groupId>\n"
    replace_2="        <artifactId>kogito-bom<\/artifactId>\n"
    replace_3="        <version>${kogito_version}<\/version>\n"
    complete_replace="$replace_1$replace_2$replace_3"

    sed -i.bak -e "/$pattern_1/{
        N;N;N
        s/$complete_pattern/$complete_replace/
        }" serverless-workflow-project/pom.xml

    rm -rf serverless-workflow-project/*.bak
fi

echo "Build quarkus app"
cd "serverless-workflow-project"
# Quarkus version is enforced if some dependency pulled has older version of Quarkus set.
# This avoids to have, for example, Quarkus BOMs or orther artifacts with multiple versions.
mvn ${MAVEN_OPTIONS} \
    -DskipTests \
    -Dmaven.repo.local=${mvn_local_repo} \
    -Dquarkus.container-image.build=false \
    clean install

cd ${build_target_dir}

#remove unnecessary files
rm -rfv serverless-workflow-project/target
rm -rfv serverless-workflow-project/src/main/resources/*
rm -rfv serverless-workflow-project/src/main/docker
rm -rfv serverless-workflow-project/.mvn/wrapper
rm -rfv serverless-workflow-project/mvnw*
rm -rfv serverless-workflow-project/src/test
rm -rfv serverless-workflow-project/*.bak

# Maven useless files
# Needed to avoid Maven to automatically redownload from original Maven repository ...
find ${mvn_local_repo} -name _remote.repositories -type f -delete
find ${mvn_local_repo} -name _maven.repositories -type f -delete
find ${mvn_local_repo} -name *.lastUpdated -type f -delete

echo "Zip and copy scaffold project"
zip -r kogito-swf-builder-quarkus-app.zip serverless-workflow-project/ 
cp -v kogito-swf-builder-quarkus-app.zip ${target_tmp_dir}/
echo "Zip and copy maven repo"
cd ${mvn_local_repo}
zip -r kogito-swf-builder-maven-repo.zip *
cp -v kogito-swf-builder-maven-repo.zip ${target_tmp_dir}/
