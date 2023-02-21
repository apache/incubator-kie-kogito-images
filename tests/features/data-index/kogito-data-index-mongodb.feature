@quay.io/kiegroup/kogito-data-index-mongodb
Feature: Kogito-data-index mongodb feature.

  Scenario: verify if all labels are correctly set on kogito-data-index-mongodb image
    Given image is built
     Then the image should contain label maintainer with value kogito <bsig-cloud@redhat.com>
      And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
      And the image should contain label io.openshift.s2i.destination with value /tmp
      And the image should contain label io.openshift.expose-services with value 8080:http
      And the image should contain label io.k8s.description with value Runtime image for Kogito Data Index Service for Mongodb persistence provider
      And the image should contain label io.k8s.display-name with value Kogito Data Index Service - Mongodb
      And the image should contain label io.openshift.tags with value kogito,data-index,data-index-mongodb

  Scenario: verify if all parameters are correctly set
    When container is started with env
      | variable                                   | value                       |
      | SCRIPT_DEBUG                               | true                        |
      | QUARKUS_MONGODB_CONNECTION_STRING          | mongodb://172.18.0.1:27071  |
      | QUARKUS_MONGODB_DATABASE                   | database                    |
      | QUARKUS_MONGODB_CREDENTIALS_AUTH_USERNAME  | IamNotExist                 |
      | QUARKUS_MONGODB_CREDENTIALS_AUTH_PASSWORD  | SecretRealm                 |
      | QUARKUS_MONGODB_CREDENTIALS_AUTH_MECHANISM | MONGODB-X509                |
    Then container log should contain QUARKUS_MONGODB_CONNECTION_STRING=mongodb://172.18.0.1:27071
     And container log should contain QUARKUS_MONGODB_DATABASE=database
     And container log should contain QUARKUS_MONGODB_CREDENTIALS_AUTH_USERNAME=IamNotExist
     And container log should contain QUARKUS_MONGODB_CREDENTIALS_AUTH_PASSWORD=SecretRealm
     And container log should contain QUARKUS_MONGODB_CREDENTIALS_AUTH_MECHANISM=MONGODB-X509


  Scenario:   Scenario: check if the default quarkus profile is correctly set on data index
    When container is started with env
      | variable               | value   |
      | SCRIPT_DEBUG           | true    |
    Then container log should contain -Dquarkus.profile=kafka-events-support

  Scenario:   Scenario: check if a provided data index quarkus profile is correctly set on data index
    When container is started with env
      | variable                           | value               |
      | SCRIPT_DEBUG                       | true                |
      | KOGITO_DATA_INDEX_QUARKUS_PROFILE  | http-events-support |
    Then container log should contain -Dquarkus.profile=http-events-support

  Scenario:   Scenario: test if a invalid value for data-index quarkus profile will set the default value
    When container is started with env
      | variable                           | value                      |
      | SCRIPT_DEBUG                       | true                       |
      | KOGITO_DATA_INDEX_QUARKUS_PROFILE  | unexisting-quarkus-profile |
    Then container log should contain -Dquarkus.profile=kafka-events-support