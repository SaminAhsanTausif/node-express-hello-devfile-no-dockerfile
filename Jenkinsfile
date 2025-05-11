pipeline {
    agent any
    environment
    {
        // Define environment variables here
        DOCKER_REGISTRY = "localhost:5000"
        DOCKER_IMAGE = "node-express-app"
        BRANCH = "dev-branch"
        GIT_URL = "https://github.com/SaminAhsanTausif/node-express-hello-devfile-no-dockerfile.git"
        IMAGE_NAME = "${DOCKER_REGISTRY}/${DOCKER_IMAGE}"  // Combine the registry and image name
    }
    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the repository
                    echo "Cloning repository from ${GIT_URL} on branch ${BRANCH}"
                    git branch: "${BRANCH}", url: "${GIT_URL}"
                }
            }
        }
        stage('Build and Tag Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    echo "Building Docker image ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                    sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE} ."
                }
            }
        }   
        stage('Push Docker Image') {
                steps {
                    script {
                        // Push the Docker image to the registry
                        echo "Pushing Docker image ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                        //sh docker login ${DOCKER_REGISTRY} --username admin --password admin
                        sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                    }
                }
        }
        stage('Deploy and Test Docker Image'){
                steps{
                    script{
                        echo "Running Docker image locally to verify"
                        sh "docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                        sh "docker stop ${IMAGE_NAME} || true"
                        sh "docker rm ${IMAGE_NAME} || true"
                        sh "docker run -d -p 3000:3000 --name ${IMAGE_NAME} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
                        sh "docker ps"
                    }
                }
        }
        } 
    // Post actions
    post {
        always {
            echo 'Pipeline execution completed.'
        }
        failure {
            echo 'Pipeline execution failed!'
        }
     }

}