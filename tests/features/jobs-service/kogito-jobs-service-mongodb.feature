@quay.io/kiegroup/kogito-jobs-service-mongodb
Feature: Kogito-jobs-service-mongodb feature.

  Scenario: verify if all labels are correctly set kogito-jobs-service image image
    Given image is built
    Then the image should contain label maintainer with value kogito <bsig-cloud@redhat.com>
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
    And the image should contain label io.openshift.s2i.destination with value /tmp
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value Runtime image for Kogito Jobs Service based on MongoDB
    And the image should contain label io.k8s.display-name with value Kogito Jobs Service based on MongoDB
    And the image should contain label io.openshift.tags with value kogito,jobs-service-mongodb
  
  Scenario: verify if the jobs service mongodb binary is available on /home/kogito/bin
    When container is started with command bash
    Then run sh -c 'ls /home/kogito/bin/jobs-service-mongodb-runner.jar' in container and immediately check its output for /home/kogito/bin/jobs-service-mongodb-runner.jar

  Scenario: verify if of container is correctly started with mongo parameters
    When container is started with env
      | variable                          | value                                          |
      | SCRIPT_DEBUG                      | true                                           |
      | QUARKUS_MONGODB_CONNECTION_STRING | mongodb://user:password@localhost:27017/admin  |
      | QUARKUS_MONGODB_DATABASE          | kogito                                         |
    Then container log should contain + exec java -XshowSettings:properties -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080 -jar /home/kogito/bin/jobs-service-mongodb-runner.jar
    And container log should contain Cluster created with settings {hosts=[localhost:27017], mode=SINGLE
    And container log should not contain Application failed to start
