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

if [ -z "$MIGRATE_DATA_INDEX" ]; then
    MIGRATE_DATA_INDEX=true
    echo "Migrating data index: $MIGRATE_DATA_INDEX"
fi

if [ -z "$MIGRATE_JOBS_SERVICE" ]; then
    MIGRATE_JOBS_SERVICE=true
    echo "Migrating jobs service: $MIGRATE_JOBS_SERVICE"
fi

if $MIGRATE_DATA_INDEX
then 
    echo DI DB ENV VARS
    echo URL=$DI_DB_URL USER=$DI_DB_USER PWD=$DI_DB_PWD

    if [ -z "$DATA_INDEX_SCHEMA" ]; then
        DATA_INDEX_SCHEMA=data-index-service
        echo "Using the data index schema: $DATA_INDEX_SCHEMA"
    fi

    # Update $DATA_INDEX_SCHEMA for data index sql files
    cd /home/default/db-migration-files/data-index
    for FILE in *; do sed -i.bak 's/$DATA_INDEX_SCHEMA/'$DATA_INDEX_SCHEMA'/' $FILE; done
    rm -rf *.bak

    echo LISTING SQL DIR: DATA-INDEX
    ls /home/default/db-migration-files/data-index

    /home/default/flyway/flyway -url="$DI_DB_URL" -user="$DI_DB_USER" -password="$DI_DB_PWD" -mixed="true" -locations="filesystem:/home/default/db-migration-files/data-index" -schemas="$DATA_INDEX_SCHEMA"  migrate
    /home/default/flyway/flyway -url="$DI_DB_URL" -user="$DI_DB_USER" -password="$DI_DB_PWD" -mixed="true" -locations="filesystem:/home/default/db-migration-files/data-index" -schemas="$DATA_INDEX_SCHEMA" info
fi

if $MIGRATE_JOBS_SERVICE
then 
    echo JS DB ENV VARS
    echo URL=$JS_DB_URL USER=$JS_DB_USER PWD=$JS_DB_PWD

    if [ -z "$JOBS_SERVICE_SCHEMA" ]; then
        JOBS_SERVICE_SCHEMA=jobs-service
        echo "Using the jobs service schema: $JOBS_SERVICE_SCHEMA"
    fi

    # Update $JOBS_SERVICE_SCHEMA for jobs service sql files
    cd /home/default/db-migration-files/jobs-service
    for FILE in *; do sed -i.bak 's/$JOBS_SERVICE_SCHEMA/'$JOBS_SERVICE_SCHEMA'/' $FILE; done
    rm -rf *.bak

    echo LISTING SQL DIR: JOBS-SERVICE
    ls /home/default/db-migration-files/jobs-service

    /home/default/flyway/flyway -url="$JS_DB_URL" -user="$JS_DB_USER" -password="$JS_DB_PWD" -mixed="true" -locations="filesystem:/home/default/db-migration-files/jobs-service" -schemas="$JOBS_SERVICE_SCHEMA"  migrate
    /home/default/flyway/flyway -url="$JS_DB_URL" -user="$JS_DB_USER" -password="$JS_DB_PWD" -mixed="true" -locations="filesystem:/home/default/db-migration-files/jobs-service" -schemas="$JOBS_SERVICE_SCHEMA" info
fi
