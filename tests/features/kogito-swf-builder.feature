@quay.io/kiegroup/kogito-swf-builder
Feature: SWF and Quarkus installation

  Scenario: verify if the maven project is under /home/kogito/kogito-base
    When container is started with command bash
    Then file /home/kogito/kogito-base/pom.xml should exist

  Scenario: verify if the swf and quarkus files are under kogito/.m2/repository
    When container is started with command bash
    Then file /home/kogito/.m2/settings.xml should exist
      And file /home/kogito/.m2/repository/org/acme/kogito-base/1.0.0-SNAPSHOT/kogito-base-1.0.0-SNAPSHOT.jar should exist
      And file /home/kogito/.m2/repository/io/quarkus/platform/quarkus-bom/2.13.0.Final/quarkus-bom-2.13.0.Final.pom should exist
      And file /home/kogito/.m2/repository/org/kie/kogito/kogito-quarkus-serverless-workflow/1.28.0.Final/kogito-quarkus-serverless-workflow-1.28.0.Final-codestarts.jar should exist

  Scenario: verify if the swf build is successful
    When container is started with command bash
    Then file /home/kogito/kogito-base/target/kogito-base-1.0.0-SNAPSHOT.jar should exist
      And file /home/kogito/kogito-base/target/quarkus-app/quarkus-run.jar should exist
      And file /home/kogito/kogito-base/target/classes/greet.sw.json should exist


  Scenario: Verify if a build run correctly
    When container is started with command bash
    Then run /usr/share/maven/bin/mvn -f /home/kogito/kogito-base -U -B clean install -DskipTests -Dmaven.repo.local=/home/kogito/.m2/repository -s /home/kogito/.m2/settings.xml -Dquarkus.container-image.build=false in container and check its output for [INFO] BUILD SUCCESS
    And file /home/kogito/kogito-base/target/quarkus-app/quarkus-run.jar should exist
    And file /home/kogito/kogito-base/target/classes/greet.sw.json should exist


