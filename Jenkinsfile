pipeline{
    agent { label 'myagent'}
    environment{
         MAVEN_MIRROR_URL="http://nexus3-kogito-tools.apps.kogito.automation.rhmw.io/repository/maven-public/"
    }
    stages{
        stage('Initialization'){
            steps{
                sh "docker rmi -f \$(docker images -q) || date"
            }
        }
        stage('Build'){
            steps{
                sh "make build"
            }
        }
        stage('Test'){
            steps{
                sh "make test"
            }
            post{
                always{
                    junit 'target/test/results/*.xml'
                }
            }
        }
        stage('Finishing'){
            steps{
                sh "docker rmi -f \$(docker images -q) || date"
            }
        }
    }
}
