@quay.io/kiegroup/kogito-runtime-jvm
@ibm-bamoe/bamoe-kogito-runtime-jvm-rhel8
Feature: kogito-runtime-jvm feature.

  Scenario: verify if the java installation is correct
    When container is started with command bash
    Then run sh -c 'echo $JAVA_HOME' in container and immediately check its output for /usr/lib/jvm/java-11
    And run sh -c 'echo $JAVA_VENDOR' in container and immediately check its output for openjdk
    And run sh -c 'echo $JAVA_VERSION' in container and immediately check its output for 11

  Scenario: Verify if the binary build is finished as expected and if it is listening on the expected port with quarkus
    Given s2i build /tmp/kogito-examples/rules-quarkus-helloworld from target
      | variable            | value                     |
      | RUNTIME_TYPE        | quarkus                   |
      | NATIVE              | false                     |
      | JAVA_OPTIONS        | -Dquarkus.log.level=DEBUG |
    Then check that page is served
      | property        | value                    |
      | port            | 8080                     |
      | path            | /hello                   |
      | request_method  | POST                     | 
      | content_type    | application/json         |
      | request_body    | {"strings":["hello"]}    |
      | wait            | 80                       |
      | expected_phrase | ["hello","world"]        |
    And file /home/kogito/bin/quarkus-run.jar should exist

  Scenario: Verify if the binary build (forcing) is finished as expected and if it is listening on the expected port with quarkus
    Given s2i build /tmp/kogito-examples/rules-quarkus-helloworld from target
      | variable            | value                     |
      | RUNTIME_TYPE        | quarkus                   |
      | NATIVE              | false                     |
      | JAVA_OPTIONS        | -Dquarkus.log.level=DEBUG |
      | BINARY_BUILD        | true                      |
    Then check that page is served
      | property        | value                    |
      | port            | 8080                     |
      | path            | /hello                   |
      | request_method  | POST                     | 
      | content_type    | application/json         |
      | request_body    | {"strings":["hello"]}    |
      | wait            | 80                       |
      | expected_phrase | ["hello","world"]        |
    And file /home/kogito/bin/quarkus-run.jar should exist

  Scenario: Verify if the binary build is finished as expected and if it is listening on the expected port with springboot
    Given s2i build /tmp/kogito-examples/ruleunit-springboot-example from target
      | variable            | value        |
      | JAVA_OPTIONS        | -Ddebug=true |
      | RUNTIME_TYPE        | springboot   |
    Then check that page is served
      | property             | value                                                                                                                      |
      | port                 | 8080                                                                                                                       |
      | path                 | /find-approved                                                                                                             |
      | wait                 | 80                                                                                                                         |
      | request_method       | POST                                                                                                                       |
      | request_body         | {"maxAmount":5000,"loanApplications":[{"id":"ABC10001","amount":2000,"deposit":100,"applicant":{"age":45,"name":"John"}}]} |
      | content_type         | application/json                                                                                                           |
      | expected_status_code | 200                                                                                                                        |
    And file /home/kogito/bin/ruleunit-springboot-example.jar should exist
    And container log should contain DEBUG 1 --- [           main] o.s.boot.SpringApplication
    And run sh -c 'echo $JAVA_OPTIONS' in container and immediately check its output for -Ddebug=true

  Scenario: Verify if the binary build (forcing) is finished as expected and if it is listening on the expected port with springboot
    Given s2i build /tmp/kogito-examples/ruleunit-springboot-example from target
      | variable            | value        |
      | JAVA_OPTIONS        | -Ddebug=true |
      | BINARY_BUILD        | true         |
      | RUNTIME_TYPE        | springboot   |
    Then check that page is served
      | property             | value                                                                                                                      |
      | port                 | 8080                                                                                                                       |
      | path                 | /find-approved                                                                                                             |
      | wait                 | 80                                                                                                                         |
      | request_method       | POST                                                                                                                       |
      | request_body         | {"maxAmount":5000,"loanApplications":[{"id":"ABC10001","amount":2000,"deposit":100,"applicant":{"age":45,"name":"John"}}]} |
      | content_type         | application/json                                                                                                           |
      | expected_status_code | 200                                                                                                                        |
    And file /home/kogito/bin/ruleunit-springboot-example.jar should exist
    And container log should contain DEBUG 1 --- [           main] o.s.boot.SpringApplication
    And run sh -c 'echo $JAVA_OPTIONS' in container and immediately check its output for -Ddebug=true
