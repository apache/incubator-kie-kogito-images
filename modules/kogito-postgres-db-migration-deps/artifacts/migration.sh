#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

# DB migration function
migrate () {
    local SERVICE_NAME=$1 # Name of service e.g. data-index or jobs-service
    local MIGRATE_DB=$2 # To migrate DB set to true
    local DB_URL=$3
    local DB_USER=$4
    local DB_PWD=$5
    local SCHEMA_NAME=$6

    if $MIGRATE_DB
    then 
        echo USING ENVIRONMENT VARS: $SERVICE_NAME
        echo URL=$DB_URL USER=$DB_USER PWD=********

        echo LISTING SQL DIR: $SERVICE_NAME
        ls /home/default/postgresql/$SERVICE_NAME

        /home/default/flyway/flyway -url="$DB_URL" -user="$DB_USER" -password="$DB_PWD" -mixed="true" -locations="filesystem:/home/default/postgresql/$SERVICE_NAME" -schemas="$SCHEMA_NAME"  migrate
        /home/default/flyway/flyway -url="$DB_URL" -user="$DB_USER" -password="$DB_PWD" -mixed="true" -locations="filesystem:/home/default/postgresql/$SERVICE_NAME" -schemas="$SCHEMA_NAME" info
    fi
}

# DB migration flag validation
function validateDBMigration() {
    local SERVICE_NAME=$1
    local MIGRATE_DB=$2
    echo Validating $SERVICE_NAME for db migration value $MIGRATE_DB

    if [ "${MIGRATE_DB}" = true ] || [ "${MIGRATE_DB}" = false ]; then
        echo "DB migration flag for service $SERVICE_NAME will be set to $MIGRATE_DB"
    else
        echo "DB migration flag for service $SERVICE_NAME, should be either true or false, but found $MIGRATE_DB, exiting"
        exit 1
    fi
}

# Process data-index
SERVICE_DATA_INDEX="data-index"

if [ -z "$MIGRATE_DATA_INDEX" ]; then
    MIGRATE_DATA_INDEX=true
else
    validateDBMigration $SERVICE_DATA_INDEX $MIGRATE_DATA_INDEX
fi
echo "Migrating data index: $MIGRATE_DATA_INDEX"

if [ -z "$DATA_INDEX_SCHEMA" ]; then
    DATA_INDEX_SCHEMA=data-index-service
    echo "Using the data index schema: $DATA_INDEX_SCHEMA"
fi

migrate $SERVICE_DATA_INDEX $MIGRATE_DATA_INDEX $DI_DB_URL $DI_DB_USER $DI_DB_PWD $DATA_INDEX_SCHEMA

# Process jobs-service
SERVICE_JOBS_SERVICE="jobs-service"

if [ -z "$MIGRATE_JOBS_SERVICE" ]; then
    MIGRATE_JOBS_SERVICE=true
else
    validateDBMigration $SERVICE_JOBS_SERVICE $MIGRATE_JOBS_SERVICE
fi
echo "Migrating jobs service: $MIGRATE_JOBS_SERVICE"

if [ -z "$JOBS_SERVICE_SCHEMA" ]; then
    JOBS_SERVICE_SCHEMA=jobs-service
    echo "Using the jobs service schema: $JOBS_SERVICE_SCHEMA"
fi

migrate $SERVICE_JOBS_SERVICE $MIGRATE_JOBS_SERVICE $JS_DB_URL $JS_DB_USER $JS_DB_PWD $JOBS_SERVICE_SCHEMA