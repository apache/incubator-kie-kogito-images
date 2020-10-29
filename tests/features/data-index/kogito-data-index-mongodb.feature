@quay.io/kiegroup/kogito-data-index-mongodb
Feature: Kogito-data-index mongodb feature.

  Scenario: verify if all labels are correctly set.
    Given image is built
     Then the image should contain label maintainer with value kogito <kogito@kiegroup.com>
      And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
      And the image should contain label io.openshift.s2i.destination with value /tmp
      And the image should contain label io.openshift.expose-services with value 8080:http
      And the image should contain label io.k8s.description with value Runtime image for Kogito Data Index Service for Mongodb persistence provider
      And the image should contain label io.k8s.display-name with value Kogito Data Index Service - Mongodb
      And the image should contain label io.openshift.tags with value kogito,data-index,data-index-mongodb

  Scenario: verify if the indexing service binaries are available on /home/kogito/bin
    When container is started with command bash
    Then run sh -c 'ls /home/kogito/bin/data-index-service-mongodb.jar' in container and immediately check its output for /home/kogito/bin/data-index-service-mongodb.jar

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

