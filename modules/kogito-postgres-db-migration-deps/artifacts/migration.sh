#!/bin/bash

echo PASSED PARAMS
echo $1 $2 $3

echo LISTING SQL DIR
ls /home/default/db-migration-files

/home/default/flyway/flyway -url="$1" -user="$2" -password="$3" -mixed="true" -locations="filesystem:/home/default/db-migration-files" -schemas="public,data-index-service,jobs-service"  migrate
/home/default/flyway/flyway -url="$1" -user="$2" -password="$3" -mixed="true" -locations="filesystem:/home/default/db-migration-files" -schemas="public,data-index-service,jobs-service" info