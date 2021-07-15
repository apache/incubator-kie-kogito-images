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

  Scenario: verify if community builder image does not contain the red hat maven repositories
    When container is started with command bash
    Then file /home/kogito/.m2/settings.xml should not contain <id>redhat-maven-repositories</id>
    And file /home/kogito/.m2/settings.xml should not contain <activeProfile>redhat-maven-repositories</activeProfile>
    And file /home/kogito/.m2/settings.xml should not contain <id>redhat-ga-repository</id>
    And file /home/kogito/.m2/settings.xml should not contain <url>https://maven.repository.redhat.com/ga/</url>
    And file /home/kogito/.m2/settings.xml should not contain <id>redhat-ea-repository</id>
    And file /home/kogito/.m2/settings.xml should not contain <url>https://maven.repository.redhat.com/earlyaccess/all/</url>
    And file /home/kogito/.m2/settings.xml should not contain <id>redhat-techpreview-repository</id>
    And file /home/kogito/.m2/settings.xml should not contain <url>https://maven.repository.redhat.com/techpreview/all</url>

  Scenario: Verify if the s2i build is finished as expected performing a non native build with persistence enabled
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-quarkus-example using 1.5.x and runtime-image quay.io/kiegroup/kogito-runtime-jvm:latest
      | variable          | value         |
      | NATIVE            | false         |
      | RUNTIME_TYPE      | quarkus       |
      | MAVEN_ARGS_APPEND | -Ppersistence |
    Then file /home/kogito/bin/quarkus-run.jar should exist
    And s2i build log should contain '/home/kogito/bin/demo.orders.proto' -> '/home/kogito/data/protobufs/demo.orders.proto'
    And s2i build log should contain '/home/kogito/bin/persons.proto' -> '/home/kogito/data/protobufs/persons.proto'

  Scenario: Verify if the s2i build is finished as expected with persistence enabled
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-springboot-example using 1.5.x and runtime-image quay.io/kiegroup/kogito-runtime-jvm:latest
      | variable          | value         |
      | MAVEN_ARGS_APPEND | -Ppersistence |
      | RUNTIME_TYPE      | springboot    |
    Then file /home/kogito/bin/process-springboot-example.jar should exist
    And s2i build log should contain '/home/kogito/bin/demo.orders.proto' -> '/home/kogito/data/protobufs/demo.orders.proto'
    And s2i build log should contain '/home/kogito/bin/persons.proto' -> '/home/kogito/data/protobufs/persons.proto'

  Scenario: Verify that the Kogito Maven archetype is generating the project and compiling it correctly
    Given s2i build /tmp/kogito-examples from dmn-example using 1.5.x and runtime-image quay.io/kiegroup/kogito-runtime-jvm:latest
      | variable       | value          |
      | RUNTIME_TYPE   | quarkus        |
      | NATIVE         | false          |
      | KOGITO_VERSION | 1.5.0.Final |      
    Then file /home/kogito/bin/project-1.0-SNAPSHOT-runner.jar should exist
    And s2i build log should contain Generating quarkus project structure using the kogito-quarkus-archetype archetype...
    And check that page is served
      | property        | value                                                                                            |
      | port            | 8080                                                                                             |
      | path            | /Traffic%20Violation                                                                             |
      | wait            | 80                                                                                               |
      | expected_phrase | Should the driver be suspended?                                                                  |
      | request_method  | POST                                                                                             |
      | content_type    | application/json                                                                                 |
      | request_body    | {"Driver": {"Points": 2}, "Violation": {"Type": "speed","Actual Speed": 120,"Speed Limit": 100}} |

  Scenario: Verify that the Kogito Maven archetype is generating the project and compiling it correctly with custom group id, archetype & version
    Given s2i build /tmp/kogito-examples from dmn-example using 1.5.x and runtime-image quay.io/kiegroup/kogito-runtime-jvm:latest
      | variable            | value          |
      | RUNTIME_TYPE        | quarkus        |
      | NATIVE              | false          |
      | KOGITO_VERSION | 1.5.0.Final |      
      | PROJECT_GROUP_ID    | com.mycompany  |
      | PROJECT_ARTIFACT_ID | myproject      |
      | PROJECT_VERSION     | 2.0-SNAPSHOT   |
    Then file /home/kogito/bin/myproject-2.0-SNAPSHOT-runner.jar should exist
    And s2i build log should contain Generating quarkus project structure using the kogito-quarkus-archetype archetype...
    And check that page is served
      | property        | value                                                                                            |
      | port            | 8080                                                                                             |
      | path            | /Traffic%20Violation                                                                             |
      | wait            | 80                                                                                               |
      | expected_phrase | Should the driver be suspended?                                                                  |
      | request_method  | POST                                                                                             |
      | content_type    | application/json                                                                                 |
      | request_body    | {"Driver": {"Points": 2}, "Violation": {"Type": "speed","Actual Speed": 120,"Speed Limit": 100}} |

#### SpringBoot Scenarios

  Scenario: Verify that the Kogito Maven archetype is generating the project and compiling it correctly when runtime is springboot
    Given s2i build /tmp/kogito-examples from dmn-example using 1.5.x and runtime-image quay.io/kiegroup/kogito-runtime-jvm:latest
      | variable       | value          |
      | KOGITO_VERSION | 1.5.0.Final |      
      | RUNTIME_TYPE   | springboot     |
    Then file /home/kogito/bin/project-1.0-SNAPSHOT.jar should exist
    And s2i build log should contain Generating springboot project structure using the kogito-springboot-archetype archetype...
    And check that page is served
      | property        | value                                                                                            |
      | port            | 8080                                                                                             |
      | path            | /Traffic%20Violation                                                                             |
      | wait            | 80                                                                                               |
      | expected_phrase | Should the driver be suspended?                                                                  |
      | request_method  | POST                                                                                             |
      | content_type    | application/json                                                                                 |
      | request_body    | {"Driver": {"Points": 2}, "Violation": {"Type": "speed","Actual Speed": 120,"Speed Limit": 100}} |
