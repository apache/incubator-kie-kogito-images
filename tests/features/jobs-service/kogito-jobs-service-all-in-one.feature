@quay.io/kiegroup/kogito-jobs-service-allinone
Feature: Kogito-jobs-service-all-in-one feature.

  Scenario: verify if all labels are correctly set kogito-jobs-service image image
    Given image is built
    Then the image should contain label maintainer with value kogito <bsig-cloud@redhat.com>
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
    And the image should contain label io.openshift.s2i.destination with value /tmp
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value Runtime image for Kogito Jobs Service with all available jdbc providers
    And the image should contain label io.k8s.display-name with value Kogito Jobs Service All-in-One
    And the image should contain label io.openshift.tags with value kogito,jobs-service,postgresql,mongodb,infinispan,ephemeral

  Scenario: Verify if all jobs-service flavors are in the image
    When container is started with command bash
    Then file /home/kogito/bin/ephemeral/quarkus-app/quarkus-run.jar should exist
    And file /home/kogito/bin/infinispan/quarkus-app/quarkus-run.jar should exist
    And file /home/kogito/bin/postgresql/quarkus-app/quarkus-run.jar should exist
    And file /home/kogito/bin/mongodb/quarkus-app/quarkus-run.jar should exist

  Scenario: Verify if the debug is correctly enabled with the ephemeral jar
    When container is started with env
      | variable     | value |
      | SCRIPT_DEBUG | true  |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/ephemeral/quarkus-app/quarkus-run.jar
    And container log should contain started in
    And container log should not contain Application failed to start

  Scenario: Infinispan - verify if auth is correctly set
    When container is started with env
      | variable                                  | value             |
      | SCRIPT_DEBUG                              | true              |
      | JOBS_SERVICE_PERSISTENCE                  | infinispan        |
      | QUARKUS_INFINISPAN_CLIENT_HOSTS           | 172.18.0.1:11222  |
      | QUARKUS_INFINISPAN_CLIENT_USE_AUTH        | true              |
      | QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME   | IamNotExist       |
      | QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD   | hard2guess        |
      | QUARKUS_INFINISPAN_CLIENT_AUTH_REALM      | SecretRealm       |
      | QUARKUS_INFINISPAN_CLIENT_SASL_MECHANISM  | COOLGSSAPI        |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/infinispan/quarkus-app/quarkus-run.jar
    And container log should contain QUARKUS_INFINISPAN_CLIENT_HOSTS=172.18.0.1:11222
    And container log should contain QUARKUS_INFINISPAN_CLIENT_USE_AUTH=true
    And container log should contain QUARKUS_INFINISPAN_CLIENT_PASSWORD=hard2guess
    And container log should contain QUARKUS_INFINISPAN_CLIENT_USERNAME=IamNotExist
    And container log should contain QUARKUS_INFINISPAN_CLIENT_AUTH_REALM=SecretReal
    And container log should contain QUARKUS_INFINISPAN_CLIENT_SASL_MECHANISM=COOLGSSAPI
    And container log should not contain Application failed to start

  Scenario: verify if the container is correctly started with mongo parameters
    When container is started with env
      | variable                          | value                                          |
      | SCRIPT_DEBUG                      | true                                           |
      | JOBS_SERVICE_PERSISTENCE          | mongodb                                        |
      | QUARKUS_MONGODB_CONNECTION_STRING | mongodb://user:password@localhost:27017/admin  |
      | QUARKUS_MONGODB_DATABASE          | kogito                                         |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/mongodb/quarkus-app/quarkus-run.jar
    And container log should not contain Application failed to start

  Scenario: verify if the container is started with invalid jobs-service flavor
    When container is started with env
      | variable                          | value      |
      | SCRIPT_DEBUG                      | true       |
      | JOBS_SERVICE_PERSISTENCE          | something  |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/ephemeral/quarkus-app/quarkus-run.jar
    And container log should contain something is not supported, the allowed flavors are [ephemeral mongodb infinispan postgresql], defaulting to ephemeral

  Scenario: verify if container starts as expected
    When container is started with env
      | variable                    | value                                                 |
      | SCRIPT_DEBUG                | true                                                  |
      | QUARKUS_LOG_LEVEL           | DEBUG                                                 |
      | JOBS_SERVICE_PERSISTENCE    | postgresql                                            |
      | QUARKUS_DATASOURCE_DB_KIND  | postgresql                                            |
      | QUARKUS_DATASOURCE_USERNAME | test                                                  |
      | QUARKUS_DATASOURCE_PASSWORD | 123456                                                |
      | QUARKUS_DATASOURCE_JDBC_URL | jdbc:postgresql://10.11.12.13:5432/hibernate_orm_test |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/postgresql/quarkus-app/quarkus-run.jar
    And container log should contain QUARKUS_DATASOURCE_DB_KIND=postgresql
    And container log should contain QUARKUS_DATASOURCE_USERNAME=test
    And container log should contain QUARKUS_DATASOURCE_PASSWORD=123456
    And container log should contain QUARKUS_DATASOURCE_JDBC_URL=jdbc:postgresql://10.11.12.13:5432/hibernate_orm_test
    And container log should contain  Trying to establish a protocol version 3 connection to 10.11.12.13:5432
