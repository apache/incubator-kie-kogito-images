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

@docker.io/apache/incubator-kie-kogito-postgres-db-migration
Feature: kogito-postgres-db-migration DB migration for postgresql feature.

  Scenario: verify if all labels are correctly set on kogito-postgres-db-migration-image image
    Given image is built
     Then the image should contain label maintainer with value Apache KIE <dev@kie.apache.org>
      And the image should contain label io.k8s.description with value Kogito DB Migration creates schemas and tables for Data Index and Jobs Service for PostgreSQL database
      And the image should contain label io.k8s.display-name with value Kogito DB Migration for Data Index and Jobs Service - PostgreSQL
      And the image should contain label io.openshift.tags with value kogito,db-migration

  Scenario: Verify log entries
    When container is started with command bash -c '/home/default/migration.sh'
    Then container log should contain LISTING SQL DIR
    And container log should contain V1.44.0__data_index_definitions.sql
    And container log should contain V2.0.1__job_details_increase_job_id_size.sql