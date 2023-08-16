pipeline {
    agent any

    tools {
        // Install the jfrog plugin and install the jfrog CLI in Manage -> Tools
        jfrog 'jfrog-cli'
    }
    environment {
        // Specify the docker image name. Change the tag here for changes that need to
        // be reflected on Artifactory.
        DOCKER_IMAGE_NAME = "nitin4jfrog.jfrog.io/docker-local/spring-petclinic:1.0.2"
    }

    stages {
        stage('Build') {
            steps {
                // Get some code from personal copy of sprint-petclinic on GitHub
                git branch: 'main', url: 'https://github.com/nitinthewiz/spring-petclinic'

                // Run Maven on a Unix agent. Compile the tests but skip running
                // them at this stage.
                sh "./mvnw -DskipTests clean package"
            }

            post {
                // Archive the jar file locally to jenkins for later use in 
                // the docker image.
                success {
                    archiveArtifacts 'target/*.jar'
                }
            }
        }

        stage('Test') {
            steps {
                // Run the tests on a Unix agent.
                sh "./mvnw test"
            }

            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results.
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
            }
        }

        stage('Build Docker image') {
            steps {
                // Use the Docker pipeline plugin to create the docker image
                script {
                    def customImage = docker.build("$DOCKER_IMAGE_NAME")
                }
            }
        }

        stage('Scan and push image') {
            steps {
                // Scan Docker image for vulnerabilities
                jf 'docker scan $DOCKER_IMAGE_NAME'

                // Push image to Artifactory. Make sure JF_ACCESS_TOKEN is configured
                // in Jenkins -> Manage -> System beforehand.
                jf 'docker push $DOCKER_IMAGE_NAME'
            }
        }

        stage('Publish build info') {
            steps {
                // Publish Build info to Artifactory.
                jf 'rt build-publish'
            }
        }
    }
}
