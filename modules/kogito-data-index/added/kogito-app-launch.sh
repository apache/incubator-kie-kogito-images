#!/usr/bin/env bash

#import
source ${KOGITO_HOME}/launch/logging.sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    SHOW_JVM_SETTINGS="-XshowSettings:properties"
    log_info "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
    log_info "JVM settings debug is enabled."
fi


# Configuration scripts
# Any configuration script that needs to run on image startup must be added here.
CONFIGURE_SCRIPTS=(
  ${KOGITO_HOME}/launch/kogito-data-index.sh
)
source ${KOGITO_HOME}/launch/configure.sh
#############################################

if [ ${DATA_INDEX_STORAGE^^} = "MONGODB" ] ; then 
      DATA_INDEX_JAR="kogito-data-index-mongodb.jar"
    else
      DATA_INDEX_JAR="kogito-data-index-infinispan.jar"
fi

printenv

exec java ${SHOW_JVM_SETTINGS} ${JAVA_OPTIONS} ${KOGITO_DATA_INDEX_PROPS} \
        -Djava.library.path=$KOGITO_HOME/lib \
        -Dquarkus.http.host=0.0.0.0 \
        -jar $KOGITO_HOME/bin/$DATA_INDEX_JAR