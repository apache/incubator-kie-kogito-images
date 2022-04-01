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
KOGITO_APPS_ORG="kiegroup"
TMPDIR="/tmp/build"

branchTag="${1:main}"
if [ "${branchTag^^}" == "2.0.0-SNAPSHOT" ]; then
    branchTag="main"
fi
mkdir -vp ${TMPDIR} && cd ${TMPDIR}

echo "Using branch/tag ${branchTag}, checking out."

if [ ! -d "${TMPDIR}/${KOGITO_APPS_REPO_NAME}" ]; then
    git clone https://github.com/kiegroup/${KOGITO_APPS_REPO_NAME}.git
fi
cd ${KOGITO_APPS_REPO_NAME} && echo "working dir `pwd`"


# On CI images are built concurrently, race conditions can make the checkout to fail with this error:
# error: pathspec 'main' did not match any file(s) known to git
counter=1
while [ $counter -le 10 ]
do
    git checkout ${branchTag}
    if [ $? != 0 ]; then
        counter=$(expr $counter + 1)
    else
        break
    fi
    echo $counter
    sleep 5
done
if [ $counter -eq 10 ]; then
    echo "Branch or tag ${branchTag} does not exist, aborting."
    exit 1
fi

echo "on branch/tag ${branchTag}, repo is ready to be built."
echo "Building component ${contextDir}"

for ctx in ${contextDir}; do
    mvn -f ${ctx} package -DskipTests -Dquarkus.package.type=fast-jar -Dquarkus.container-image.build=false
    cd ${ctx}/target/
    zip -r $(basename ${ctx})-quarkus-app.zip quarkus-app
    cd -
done
