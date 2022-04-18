#!/usr/bin/env bash
# Holds common maven configuration for CI;
# Usage: . setup-maven.sh

MAVEN_VERSION="3.8.x"
SCRIPT_DIR=""
IFS='/' read -ra ADDR <<< `pwd`
for d in "${ADDR[@]}"; do
    if [ "${d}" != "" ]; then
        current=$current/$d
    fi
    if [ "${d}" == "kogito-images" ]; then
        SCRIPT_DIR="${current}"
        break
    fi
done

MVN_MODULE="${SCRIPT_DIR}/modules/kogito-maven/${MAVEN_VERSION}"
MAVEN_OPTIONS="-DskipTests"

if [ "${CI}" ]; then
    # setup maven env
    export JBOSS_MAVEN_REPO_URL="https://repository.jboss.org/nexus/content/groups/public/"
    # export MAVEN_REPO_URL=
    cp "${MVN_MODULE}"/maven/settings.xml "${HOME}"/.m2/settings.xml
    source "${MVN_MODULE}"/added/configure-maven.sh
    configure

    cat "${HOME}"/.m2/settings.xml
fi

if [ "${MAVEN_IGNORE_SELF_SIGNED_CERTIFICATE}" = "true" ]; then
    MAVEN_OPTIONS="${MAVEN_OPTIONS} -Denforcer.skip"
fi


