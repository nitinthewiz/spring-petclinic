pipeline {
    agent any

    tools {
        jfrog 'jfrog-cli'
    }
    environment {
        DOCKER_IMAGE_NAME = "nitin4jfrog.jfrog.io/docker-local/spring-petclinic:1.0.1"
    }

    stages {
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                git branch: 'main', url: 'https://github.com/nitinthewiz/spring-petclinic'

                // Run Maven on a Unix agent.
                sh "./mvnw -DskipTests clean package"

                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }

            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    archiveArtifacts 'target/*.jar'
                }
            }
        }

        stage('Test') {
            steps {
                sh "./mvnw test"
            }

            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    def customImage = docker.build("$DOCKER_IMAGE_NAME")
                }
            }
        }

        stage('Scan and push image') {
            steps {
                // Scan Docker image for vulnerabilities
                jf 'docker scan $DOCKER_IMAGE_NAME'

                // Push image to Artifactory
                jf 'docker push $DOCKER_IMAGE_NAME'
            }
        }

        stage('Publish build info') {
            steps {
                jf 'rt build-publish'
            }
        }
    }
}
