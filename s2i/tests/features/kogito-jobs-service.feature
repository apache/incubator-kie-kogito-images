@quay.io/kiegroup/kogito-jobs-service

Feature: Kogito-data-index feature.

  Scenario: verify if all labels are correctly set.
    Given image is built
    Then the image should contain label maintainer with value kogito <kogito@kiegroup.com>
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
    And the image should contain label io.openshift.s2i.destination with value /tmp
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value Runtime image for Kogito Jobs Service
    And the image should contain label io.k8s.display-name with value Kogito Jobs Service
    And the image should contain label io.openshift.tags with value kogito,jobs-service

  Scenario: verify if the binary is available on /home/kogito/bin
    When container is started with command bash
    Then run sh -c 'ls /home/kogito/bin/kogito-jobs-service-runner.jar' in container and immediately check its output for /home/kogito/bin/kogito-jobs-service-runner.jar

  Scenario: Verify if the debug is correctly enabled
    When container is started with env
      | variable     | value |
      | SCRIPT_DEBUG | true  |
    Then container log should contain + exec java -XshowSettings:properties -jar /home/kogito/bin/kogito-jobs-service-runner.jar

  Scenario: verify if the persistence is correctly enabled
    When container is started with env
      | variable            | value |
      | ENABLE_PERSISTENCE  | true  |
     Then container log should contain Connecting org.kie.kogito.jobs.service.stream.JobStreams#jobSuccessProcessor
