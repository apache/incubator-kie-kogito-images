@quay.io/kiegroup/kogito-jobs-service-ephemeral
Feature: Kogito-jobs-service-ephemeral feature.

  Scenario: verify if all labels are correctly set kogito-jobs-service image image
    Given image is built
    Then the image should contain label maintainer with value kogito <bsig-cloud@redhat.com>
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value Runtime image for Kogito in memory Jobs Service
    And the image should contain label io.k8s.display-name with value Kogito in memory Jobs Service
    And the image should contain label io.openshift.tags with value kogito,jobs-service-ephemeral

  Scenario: Verify if the application jar exists
    When container is started with command bash
    Then run sh -c 'ls /home/kogito/bin/ephemeral/quarkus-app/quarkus-run.jar' in container and immediately check its output for /home/kogito/bin/ephemeral/quarkus-app/quarkus-run.jar

  Scenario: Verify if the debug is correctly enabled with the ephemeral jar
    When container is started with env
      | variable     | value |
      | SCRIPT_DEBUG | true  |
    Then container log should contain -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/ephemeral/quarkus-app/quarkus-run.jar
    And container log should contain started in
    And container log should not contain Application failed to start

