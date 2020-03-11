pipeline{
 agent { label 'myagent'}
 stages{
  stage('Initializing'){
     steps{
     sh """
         pwd
         ls -l
         export PATH=/usr/local/bin/:$PATH
         docker rmi -f \$(docker images -q) || date
         rm -rf /root/kogito-cloud/
         mkdir -p /root/kogito-cloud
   """
   }
  }
     stage('Clone Sources'){
         steps{
         sh """
         git clone https://github.com/kiegroup/kogito-cloud.git  /root/kogito-cloud
         """
        }
    }
  stage('Update Maven Artifacts'){
   steps{
   sh """
   python /root/python-scripts/update-data-service-index-url
   python /root/python-scripts/update_jobs_service_url
   """
   }
  }
   stage('Build'){
       steps{
           withDockerRegistry([ credentialsId: "tarkhand-rregistry", url: "https://registry.redhat.io" ]){
               sh """ 
               export MAVEN_MIRROR_URL=http://nexus3-kogito-tools.apps.kogito.automation.rhmw.io/repository/maven-public/
               cd /root/kogito-cloud/s2i && make build
               """
           }
       }
   }
   stage('Test'){
       steps{
           sh """
           export MAVEN_MIRROR_URL=http://nexus3-kogito-tools.apps.kogito.automation.rhmw.io/repository/maven-public/
           cd /root/kogito-cloud/s2i && make test
           """
       }
   }

 stage('Tagging'){
      steps{
          sh """
             docker tag quay.io/kiegroup/kogito-jobs-service:0.8.0-rc1             quay.io/kaitou786/kogito-jobs-service-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-jobs-service                       quay.io/kaitou786/kogito-jobs-service-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-data-index:0.8.0-rc1               quay.io/kaitou786/kogito-data-index-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-data-index                         quay.io/kaitou786/kogito-data-index-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-springboot-ubi8-s2i:0.8.0-rc1      quay.io/kaitou786/kogito-springboot-ubi8-s2i-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-springboot-ubi8-s2i                quay.io/kaitou786/kogito-springboot-ubi8-s2i-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-springboot-ubi8:0.8.0-rc1          quay.io/kaitou786/kogito-springboot-ubi8-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-springboot-ubi8                    quay.io/kaitou786/kogito-springboot-ubi8-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-quarkus-ubi8-s2i:0.8.0-rc1         quay.io/kaitou786/kogito-quarkus-ubi8-s2i-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-quarkus-ubi8-s2i                   quay.io/kaitou786/kogito-quarkus-ubi8-s2i-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-quarkus-jvm-ubi8:0.8.0-rc1         quay.io/kaitou786/kogito-quarkus-jvm-ubi8-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-quarkus-jvm-ubi8                   quay.io/kaitou786/kogito-quarkus-jvm-ubi8-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-quarkus-ubi8:0.8.0-rc1             quay.io/kaitou786/kogito-quarkus-ubi8-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker tag quay.io/kiegroup/kogito-quarkus-ubi8                       quay.io/kaitou786/kogito-quarkus-ubi8-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
             docker images
             """
       }
  }
  stage('Pushing'){
   steps{
   withDockerRegistry([ credentialsId: "tarun_quay", url: "https://quay.io" ]){
    sh """
    docker push  quay.io/kaitou786/kogito-jobs-service-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-jobs-service-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-data-index-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-data-index-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-springboot-ubi8-s2i-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-springboot-ubi8-s2i-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-springboot-ubi8-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-springboot-ubi8-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-quarkus-ubi8-s2i-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-quarkus-ubi8-s2i-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-quarkus-jvm-ubi8-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-quarkus-jvm-ubi8-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-quarkus-ubi8-nightly:0.8.0-rc1-nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    docker push  quay.io/kaitou786/kogito-quarkus-ubi8-nightly:nightly-\$(echo \${GIT_COMMIT} | cut -c1-7)
    """
   }
   }  
  }
   stage('Finishing'){
       steps{
           sh"""
           rm -rf /root/kogito-cloud
           docker rmi -f \$(docker images -q) || date
           """
       }
   }
 }
}
