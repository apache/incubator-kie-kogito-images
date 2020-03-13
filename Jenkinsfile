pipeline{
 agent { label 'myagent'}
 stages{
  stage('Initializing'){
     steps{
     sh """
        #git checkout $ghprbSourceBranch
        #echo $sha1
         ls -l
         docker rmi -f \$(docker images -q) || date
   """
   }
  }
  stage('Update Maven Artifacts'){
   steps{
   sh """
   git branch
   cp /root/python-scripts/update-data-service-index-url .
   cp /root/python-scripts/update_jobs_service_url .
   python update_jobs_service_url
   python update-data-service-index-url
   """
   }
  }
   stage('Build'){
       steps{
           withDockerRegistry([ credentialsId: "tarkhand-rregistry", url: "https://registry.redhat.io" ]){
               sh """ 
               git branch
               ls -l
               export MAVEN_MIRROR_URL=http://nexus3-kogito-tools.apps.kogito.automation.rhmw.io/repository/maven-public/
               cd s2i && make build
               """
           }
       }
   }
   stage('Test'){
       steps{
           sh """
           git branch
           ls -l
           export MAVEN_MIRROR_URL=http://nexus3-kogito-tools.apps.kogito.automation.rhmw.io/repository/maven-public/
           cd s2i && make test
           """
       }
   }
   stage('Finishing'){
       steps{
           sh"""
           docker rmi -f \$(docker images -q) || date
           """
       }
   }
 }
}
