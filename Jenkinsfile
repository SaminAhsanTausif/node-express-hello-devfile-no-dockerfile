pipeline {
    agent any
    parameters {
        // Define environment variables here
        string(name: 'BRANCH', description: 'Branch to build')
        string(name: 'GIT_URL', description: 'Git repository URL')
        string(name: 'DOCKER_REGISTRY', description: 'Docker registry URL')
        string(name: 'DOCKER_IMAGE', description: 'Docker image name')
        string(name: 'CONTAINER_NAME', description: 'Docker container name')
        //credentials(name: 'DOCKER_CREDENTIALS', description: 'Credentials for Docker registry')
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
                        sh "docker stop ${params.CONTAINER_NAME} || true"
                        sh "docker rm ${params.CONTAINER_NAME} || true"
                        sh "docker run -d -p 3000:3000 --name ${params.CONTAINER_NAME} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
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