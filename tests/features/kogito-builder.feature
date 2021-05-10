@quay.io/kiegroup/kogito-builder
Feature: kogito-builder image tests

  Scenario: verify if all labels are correctly set on kogito-builder image
    Given image is built
    Then the image should contain label maintainer with value kogito <bsig-cloud@redhat.com>
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
    And the image should contain label io.openshift.s2i.destination with value /tmp
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value Platform for building Kogito based on Quarkus or Spring Boot
    And the image should contain label io.k8s.display-name with value Kogito based on Quarkus or Spring Boot
    And the image should contain label io.openshift.tags with value builder,kogito,quarkus,springboot

