@quay.io/kiegroup/kogito-trusty-postgresql
Feature: Kogito-trusty postgresql feature.

  Scenario: verify if all labels are correctly set on kogito-trusty-postgresql image
    Given image is built
     Then the image should contain label maintainer with value kogito <bsig-cloud@redhat.com>
      And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
      And the image should contain label io.openshift.s2i.destination with value /tmp
      And the image should contain label io.openshift.expose-services with value 8080:http
      And the image should contain label io.k8s.description with value Runtime image for Kogito Trusty Service for PostgreSQL persistence provider
      And the image should contain label io.k8s.display-name with value Kogito Trusty Service - PostgreSQL
      And the image should contain label io.openshift.tags with value kogito,trusty,trusty-postgresql

  Scenario: verify if the trusty service binaries are available on /home/kogito/bin
    When container is started with command bash
    Then run sh -c 'ls /home/kogito/bin/trusty-service-postgresql-runner.jar' in container and immediately check its output for /home/kogito/bin/trusty-service-postgresql-runner.jar

  Scenario: verify if all parameters are correctly set
    When container is started with env
      | variable                     | value                                     |
      | SCRIPT_DEBUG                 | true                                      |
      | QUARKUS_DATASOURCE_JDBC_URL  | jdbc:postgresql://localhost:5432/quarkus  |
      | QUARKUS_DATASOURCE_USERNAME  | kogito                                    |
      | QUARKUS_DATASOURCE_PASSWORD  | s3cr3t                                    |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/trusty-service-postgresql-runner.jar
    And container log should contain Datasource '<default>': Connection to localhost:5432 refused
