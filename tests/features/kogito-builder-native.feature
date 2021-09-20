@quay.io/kiegroup/kogito-builder
Feature: kogito-builder image native build tests

  Scenario: verify java cacerts and libsunec are available in the given kogito builder container.
    When container is started with command bash
    Then  file /home/kogito/ssl-libs/libsunec.so should exist
    And file /home/kogito/cacerts should exist

  Scenario: verify if the maven and graal vm settings are correct on kogito-builder image for native
    When container is started with command bash
    Then run sh -c 'echo $MAVEN_HOME' in container and immediately check its output for /usr/share/maven
    And run sh -c 'echo $MAVEN_VERSION' in container and immediately check its output for 3.8.1
    And run sh -c 'echo $JAVA_HOME' in container and immediately check its output for /usr/lib/jvm/java-11
    And run sh -c 'echo $GRAALVM_HOME' in container and immediately check its output for /usr/share/graalvm
    And run sh -c 'echo $GRAALVM_VERSION' in container and immediately check its output for 21.1.0

  Scenario: Verify if the s2i build is finished as expected using native build and runtime image
    Given s2i build https://github.com/kiegroup/kogito-examples.git from rules-quarkus-helloworld using nightly-main and runtime-image quay.io/kiegroup/kogito-runtime-native:latest
      | variable     | value      |
      | NATIVE       | true       |
      | RUNTIME_TYPE | quarkus    |
      | LIMIT_MEMORY | 3221225472 |
    Then check that page is served
      | property        | value                 |
      | port            | 8080                  |
      | path            | /hello                |
      | request_method  | POST                  |
      | content_type    | application/json      |
      | request_body    | {"strings":["hello"]} |
      | wait            | 80                    |
      | expected_phrase | ["hello","world"]     |
    And file /home/kogito/bin/rules-quarkus-helloworld-runner should exist
    And s2i build log should contain -J-Xmx4g

  Scenario: Verify if the s2i build is finished as expected using native build and no runtime image
    Given s2i build https://github.com/kiegroup/kogito-examples.git from rules-quarkus-helloworld using nightly-main
      | variable | value          |
      | NATIVE       | true       |
      | RUNTIME_TYPE | quarkus    |
      | LIMIT_MEMORY | 3221225472 |
    Then check that page is served
      | property        | value                 |
      | port            | 8080                  |
      | path            | /hello                |
      | request_method  | POST                  |
      | content_type    | application/json      |
      | request_body    | {"strings":["hello"]} |
      | wait            | 80                    |
      | expected_phrase | ["hello","world"]     |
    And file /home/kogito/bin/rules-quarkus-helloworld-runner should exist
    And file /home/kogito/ssl-libs/libsunec.so should exist
    And file /home/kogito/cacerts should exist
    And s2i build log should contain -J-Xmx4g

  Scenario: Verify if the s2i build is finished as expected performing a native build and if it is listening on the expected port, test uses custom properties file to test the port configuration.
    Given s2i build /tmp/kogito-examples from rules-quarkus-helloworld using nightly-main and runtime-image quay.io/kiegroup/kogito-runtime-native:latest
      | variable     | value      |
      | NATIVE       | true       |
      | RUNTIME_TYPE | quarkus    |
      | LIMIT_MEMORY | 6442450944 |
    Then check that page is served
      | property        | value                 |
      | port            | 8080                  |
      | path            | /hello                |
      | request_method  | POST                  |
      | content_type    | application/json      |
      | request_body    | {"strings":["hello"]} |
      | wait            | 80                    |
      | expected_phrase | ["hello","world"]     |
    And file /home/kogito/bin/rules-quarkus-helloworld-runner should exist

## Begin ##############################################
  # this tests had to be broken in 2, when container starts to check the file in there, Quarkus app fails to start very quick
  # thus behave fails when trying to check if the build binary was correctly copied to the runtime image.
  # Step 1 - build the image and copy the output files to the runtime image
  Scenario: Verify if the s2i build is finished as expected performing a native build with persistence enabled - Step 1: build the application and copy to the runtime image
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-quarkus-example using nightly-main and runtime-image quay.io/kiegroup/kogito-runtime-native:latest
      | variable          | value         |
      | RUNTIME_TYPE      | quarkus       |
      | NATIVE            | true          |
      | LIMIT_MEMORY      | 6442450944    |
      | MAVEN_ARGS_APPEND | -Ppersistence |
    Then s2i build log should contain '/home/kogito/bin/demo.orders.proto' -> '/home/kogito/data/protobufs/demo.orders.proto'
     And s2i build log should contain '/home/kogito/bin/persons.proto' -> '/home/kogito/data/protobufs/persons.proto'

  # Step 2 - verify if the built binary is at the expected place.
  Scenario: Verify if the s2i build is finished as expected performing a native build with persistence enabled - Step 2: check generated binary at the generated runtime image
    # integ- is appended to the container name when ts2i is called.
    # container = Container(name + context.config.userdata['IMAGE'], name=context.scenario.name)
    # it expects the name the prefix (integ- created by s2i) + the target container name quay.io/kiegroup/kogito-builder:2.0.0-snapshot
    When container integ- is started with command bash
    Then file /home/kogito/bin/process-quarkus-example-runner should exist
## End ###############################################

  Scenario: Perform a incremental s2i build for native test
    Given s2i build https://github.com/kiegroup/kogito-examples.git from rules-quarkus-helloworld with env and incremental using nightly-main
      | variable     | value   |
      | RUNTIME_TYPE | quarkus |
      | NATIVE       | false   |
    Then s2i build log should not contain WARNING: Clean build will be performed because of error saving previous build artifacts
    And file /home/kogito/bin/quarkus-run.jar should exist
    And check that page is served
      | property        | value                 |
      | port            | 8080                  |
      | path            | /hello                |
      | request_method  | POST                  |
      | content_type    | application/json      |
      | request_body    | {"strings":["hello"]} |
      | wait            | 80                    |
      | expected_phrase | ["hello","world"]     |

  # Since the same image is used we can do a subsequent incremental build and verify if it is working as expected.
  Scenario:Perform a second incremental s2i build for native scenario, this time, with native enabled
    Given s2i build https://github.com/kiegroup/kogito-examples.git from rules-quarkus-helloworld with env and incremental using nightly-main
      | variable     | value      |
      | RUNTIME_TYPE | quarkus    |
      | NATIVE       | true       |
      | LIMIT_MEMORY | 6442450944 |
    Then s2i build log should contain Expanding artifacts from incremental build...
    And s2i build log should not contain WARNING: Clean build will be performed because of error saving previous build artifacts
    And file /home/kogito/bin/rules-quarkus-helloworld-runner should exist
    And check that page is served
      | property        | value                 |
      | port            | 8080                  |
      | path            | /hello                |
      | request_method  | POST                  |
      | content_type    | application/json      |
      | request_body    | {"strings":["hello"]} |
      | wait            | 80                    |
      | expected_phrase | ["hello","world"]     |

  Scenario: Verify that the Kogito Maven archetype is generating the project and compiling it correctly using native build
    Given s2i build /tmp/kogito-examples from dmn-example using nightly-main and runtime-image quay.io/kiegroup/kogito-runtime-native:latest
      | variable       | value          |
      | RUNTIME_TYPE   | quarkus        |
      | NATIVE         | true           |
      | LIMIT_MEMORY   | 6442450944     |
      | KOGITO_VERSION | 2.0.0-SNAPSHOT |  
    Then file /home/kogito/bin/project-1.0-SNAPSHOT-runner should exist
    And check that page is served
      | property        | value                                                                                            |
      | port            | 8080                                                                                             |
      | path            | /Traffic%20Violation                                                                             |
      | wait            | 80                                                                                               |
      | expected_phrase | Should the driver be suspended?                                                                  |
      | request_method  | POST                                                                                             |
      | content_type    | application/json                                                                                 |
      | request_body    | {"Driver": {"Points": 2}, "Violation": {"Type": "speed","Actual Speed": 120,"Speed Limit": 100}} |
    And check that page is served
      | property        | value                           |
      | port            | 8080                            |
      | path            | /q/health/live                  |
      | wait            | 80                              |
      | request_method  | GET                             |
      | content_type    | application/json                |
      | request_body    | {"status": "UP", "checks": []}  |
