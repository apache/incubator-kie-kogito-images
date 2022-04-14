#!/usr/bin/env bash
# exit codes:
#   1  - git branch or tag not found
# Clone the kogito-apps to perform fast-jar builds from sources.apps

imageName="${2}"
contextDir=""

case ${imageName} in
    "kogito-management-console")
        contextDir="management-console"
        ;;
    "kogito-task-console")
        contextDir="task-console"
        ;;
    "kogito-data-index-ephemeral")
        contextDir="data-index/data-index-service/data-index-service-inmemory"
        ;;
    "kogito-data-index-infinispan")
        contextDir="data-index/data-index-service/data-index-service-infinispan"
        ;;
    "kogito-data-index-mongodb")
        contextDir="data-index/data-index-service/data-index-service-mongodb"
        ;;
    "kogito-data-index-oracle")
        contextDir="data-index/data-index-service/data-index-service-oracle"
        ;;
    "kogito-data-index-postgresql")
        contextDir="data-index/data-index-service/data-index-service-postgresql"
        ;;
    "kogito-jobs-service-ephemeral")
        contextDir="jobs-service/jobs-service-inmemory"
        ;;
    "kogito-jobs-service-infinispan")
        contextDir="jobs-service/jobs-service-infinispan"
        ;;
    "kogito-jobs-service-mongodb")
        contextDir="jobs-service/jobs-service-mongodb"
        ;;
    "kogito-jobs-service-postgresql")
        contextDir="jobs-service/jobs-service-postgresql"
        ;;
    "kogito-trusty-infinispan")
        contextDir="trusty/trusty-service/trusty-service-infinispan"
        ;;
    "kogito-trusty-postgresql")
        contextDir="trusty/trusty-service/trusty-service-postgresql"
        ;;
    "kogito-trusty-redis")
        contextDir="trusty/trusty-service/trusty-service-redis"
        ;;
    "kogito-trusty-ui")
        contextDir="trusty-ui"
        ;;
    "kogito-explainability")
        contextDir="explainability/explainability-service-messaging explainability/explainability-service-rest"
        ;;
    "kogito-jit-runner")
        contextDir="jitexecutor/jitexecutor-runner"
        ;;
    *)
        echo "${imageName} is not a supporting service image, exiting..."
        exit 0
        ;;
esac

KOGITO_APPS_REPO_NAME="kogito-apps"

for ctx in ${contextDir}; do
    target_tmp_dir="/tmp/build/$(basename ${ctx})"
    build_target_dir="/tmp/$(basename ${ctx})"
    rm -rf ${target_tmp_dir} && mkdir -p ${target_tmp_dir}
    rm -rf ${build_target_dir} && mkdir -p ${build_target_dir}
    cd ${build_target_dir}

    branchTag="${1:main}"
    if [ "${branchTag^^}" == "2.0.0-SNAPSHOT" ]; then
        branchTag="main"
    fi

    echo "Using branch/tag ${branchTag}, checking out. Temporary build dir is ${build_target_dir} and target dis is ${target_tmp_dir}"

    if [ ! -d "${build_target_dir}/${KOGITO_APPS_REPO_NAME}" ]; then
        git clone https://github.com/kiegroup/${KOGITO_APPS_REPO_NAME}.git
    fi
    cd ${KOGITO_APPS_REPO_NAME} && echo "working dir `pwd`"
    echo "Building component(s) ${contextDir}"
    mvn -am -pl ${ctx} package -DskipTests -Dquarkus.package.type=fast-jar -Dquarkus.container-image.build=false
    cd ${ctx}/target/
    zip -r $(basename ${ctx})-quarkus-app.zip quarkus-app
    cp -v $(basename ${ctx})-quarkus-app.zip ${target_tmp_dir}/
    cd -
done
