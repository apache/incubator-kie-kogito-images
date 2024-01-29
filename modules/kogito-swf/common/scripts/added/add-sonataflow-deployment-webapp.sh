#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

# This script adds SonataFlow Deployment Webapp to the pom.xml

set -e

sed -i.bak '/^  <properties>/a\
    <sonataFlowDeploymentWebapp.version>'"$SONATAFLOW_DEPLOYMENT_WEBAPP_VERSION"'<\/sonataFlowDeploymentWebapp.version>' pom.xml

sed -i.bak '/^  <dependencies>/a\
    <dependency>\
        <groupId>org.webjars.npm<\/groupId>\
        <artifactId>sonataflow-deployment-webapp<\/artifactId>\
        <version>${sonataFlowDeploymentWebapp.version}<\/version>\
    <\/dependency>' pom.xml

sed -i.bak '/<plugins>/a\
        <plugin>\
            <groupId>org.apache.maven.plugins<\/groupId>\
            <artifactId>maven-dependency-plugin<\/artifactId>\
            <executions>\
                <execution>\
                    <id>unpack-sonataflow-deployment-webapp<\/id>\
                    <phase>process-resources<\/phase>\
                    <goals>\
                        <goal>unpack<\/goal>\
                    <\/goals>\
                    <configuration>\
                        <artifactItems>\
                            <artifactItem>\
                                <groupId>org.webjars.npm<\/groupId>\
                                <artifactId>sonataflow-deployment-webapp<\/artifactId>\
                                <version>${sonataFlowDeploymentWebapp.version}<\/version>\
                                <outputDirectory>${project.build.directory}\/sonataflow-deployment-webapp<\/outputDirectory>\
                            <\/artifactItem>\
                        <\/artifactItems>\
                        <overWriteReleases>false<\/overWriteReleases>\
                        <overWriteSnapshots>true<\/overWriteSnapshots>\
                    <\/configuration>\
                <\/execution>\
            <\/executions>\
        <\/plugin>\
        <plugin>\
            <groupId>org.apache.maven.plugins<\/groupId>\
            <artifactId>maven-resources-plugin<\/artifactId>\
            <executions>\
                <execution>\
                    <id>copy-sonataflow-deployment-webapp-resources<\/id>\
                    <phase>process-resources<\/phase>\
                    <goals>\
                        <goal>copy-resources<\/goal>\
                    <\/goals>\
                    <configuration>\
                        <outputDirectory>${project.basedir}\/src\/main\/resources\/META-INF\/resources<\/outputDirectory>\
                        <overwrite>true<\/overwrite>\
                        <resources>\
                            <resource>\
                                <directory>${project.build.directory}\/sonataflow-deployment-webapp\/META-INF\/resources\/webjars\/sonataflow-deployment-webapp\/${sonataFlowDeploymentWebapp.version}\/dist<\/directory>\
                                <includes>**\/*<\/includes>\
                            <\/resource>\
                        <\/resources>\
                    <\/configuration>\
                <\/execution>\
            <\/executions>\
        <\/plugin>' pom.xml
