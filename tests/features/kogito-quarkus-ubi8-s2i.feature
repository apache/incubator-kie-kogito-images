@quay.io/kiegroup/kogito-quarkus-ubi8-s2i
Feature: kogito-quarkus-ubi8-s2i image tests
  Scenario: Verify if the s2i build is finished as expected performing a native build with persistence enabled
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-quarkus-example using master and runtime-image quay.io/kiegroup/kogito-quarkus-ubi8:latest
      | variable | value |
      | NATIVE            | true          |
      | LIMIT_MEMORY      | 6442450944    |
      | MAVEN_ARGS_APPEND | -Ppersistence |
    Then run sh -c 'cat /home/kogito/data/protobufs/persons-md5.txt' in container and immediately check its output for b19f6d73a0a1fea0bfbd8e2e30701d78
    And run sh -c 'cat /home/kogito/data/protobufs/demo.orders-md5.txt' in container and immediately check its output for 02b40df868ebda3acb3b318b6ebcc055
    And file /home/kogito/bin/process-quarkus-example-runner should exist
    And s2i build log should contain '/home/kogito/bin/demo.orders.proto' -> '/home/kogito/data/protobufs/demo.orders.proto'
    And s2i build log should contain '/home/kogito/bin/persons.proto' -> '/home/kogito/data/protobufs/persons.proto'
    And s2i build log should contain ---> [persistence] generating md5 for persistence files
    And s2i build log should contain [persistence] Generated checksum for /home/kogito/data/protobufs/persons.proto with the name: /home/kogito/data/protobufs/persons-md5.txt
    And s2i build log should contain [persistence] Generated checksum for /home/kogito/data/protobufs/demo.orders.proto with the name: /home/kogito/data/protobufs/demo.orders-md5.txt
