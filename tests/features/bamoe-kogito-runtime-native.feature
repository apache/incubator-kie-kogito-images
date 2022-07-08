@ibm-bamoe/bamoe-kogito-runtime-native-rhel8
Feature: rhpam-kogito-runtime-jvm feature.

  Scenario: verify if all labels are correctly set on rhpam-kogito-runtime-jvm-rhel8 image
    Given image is built
    # Then the image should not contain label maintainer TODO add support to this sentence on cekit behave steps
    Then the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
    And the image should contain label io.openshift.s2i.destination with value /tmp
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value IBM BAMOE Runtime image for Kogito based on Quarkus native image
    And the image should contain label io.k8s.display-name with value IBM build of Kogito runtime based on Quarkus native image
    And the image should contain label io.openshift.tags with value ibm-bamoe-kogito,runtime,kogito,quarkus,native
    And the image should contain label io.openshift.s2i.assemble-input-files with value /home/kogito/bin
    And the image should contain label com.ibm.component with value ibm-bamoe-8-runtime-native-rhel8-container

