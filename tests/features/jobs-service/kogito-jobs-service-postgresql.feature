@quay.io/kiegroup/kogito-jobs-service-postgresql
Feature: Kogito-jobs-service-postgresql feature.

  Scenario: verify if all labels are correctly set kogito-jobs-service image image
    Given image is built
    Then the image should contain label maintainer with value kogito <bsig-cloud@redhat.com>
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
    And the image should contain label io.openshift.s2i.destination with value /tmp
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value Runtime image for Kogito Jobs Service based on Postgresql
    And the image should contain label io.k8s.display-name with value Kogito Jobs Service based on Postgresql
    And the image should contain label io.openshift.tags with value kogito,jobs-service-postgresql
  
  Scenario: verify if the jobs service postgresql binary is available on /home/kogito/bin
    When container is started with command bash
    Then run sh -c 'ls /home/kogito/bin/jobs-service-postgresql-runner.jar' in container and immediately check its output for /home/kogito/bin/jobs-service-postgresql-runner.jar

  Scenario: verify if of container is correctly started with postgresql parameters
    When container is started with env
      | variable                     | value                                    |
      | SCRIPT_DEBUG                 | true                                     |
      | QUARKUS_DATASOURCE_JDBC_URL  | jdbc:postgresql://10.1.1.10:5432/quarkus |
      | QUARKUS_DATASOURCE_USERNAME  | kogito                                   |
      | QUARKUS_DATASOURCE_PASSWORD  | s3cr3t                                   |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/jobs-service-postgresql-runner.jar
    And container log should contain org.postgresql.util.PSQLException: The connection attempt failed
    And container log should not contain Application failed to start
