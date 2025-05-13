
#### Explanation of Key Sections of Dockerfile:

##### FROM node:16-alpine
##### Uses an official Node.js image based on Alpine Linux, which is lightweight and efficient.

##### ARG ENV=development
##### Defines an argument that defaults to development. You can pass production during build time if needed.

##### ENV NODE_ENV $ENV
##### Sets the environment variable NODE_ENV to development or production based on the argument passed.

##### WORKDIR
##### Sets the working directory for your app in the container.

##### *COPY package.json ./**
##### Copies only package.json and package-lock.json first, so that npm install runs faster by utilizing cached layers.

##### RUN npm install
##### Installs all dependencies defined in package.json.

##### COPY . .: Copies the rest of the project files into the container.

##### EXPOSE 3000: Exposes the port that your app will run on (adjust if needed).

##### CMD ["npm", "start"] 
##### The default command to start the app. Make sure npm start is configured in package.json

#### Docker Registry Setup

##### Step 1: Pull the Docker Registry Image
##### sudo docker pull registry:2
##### This will download the latest version of the official Docker registry image from Docker Hub.

##### Step 2: Run the Docker Registry Container
##### To start a local Docker registry on port 5000, use the following command:
##### docker run -d -p 5000:5000 --name registry registry:2

##### Explanation:

##### -d: Run in detached mode

##### -p 5000:5000: Maps port 5000 on local machine to port 5000 inside the container (-p 5000:5000).

##### --name registry: Name the container 'registry
##### Uses the Docker registry version 2 image (registry:2).

##### Step 3: Verify the Registry is Running

##### Check if the registry is up and running:
##### sudo docker ps
##### We should see a container with the name registry running on port 5000.

##### Inspect logs for issues: sudo docker logs registry

##### Run Jenkins inside a Docker container
##### 1. Pull the Jenkins Docker Image
##### First, we'll need to pull the official Jenkins Docker image from Docker Hub.
##### Jenkins provides an official image that we can easily use.

##### To do this, open the terminal and run the following command: docker pull jenkins/jenkins:lts
##### jenkins/jenkins:lts: This is the official Jenkins image, and lts stands for the Long-Term Support version of Jenkins, which is recommended for stability and security.

##### This command will download the Jenkins image to local machine.

##### 2. Create a Jenkins Container
##### Once the Jenkins image has been downloaded, we can run it in a container.
##### We need to use the following command to start Jenkins:
##### docker run -d --name jenkins -p 8080:8080  -p 50000:50000 --volume jenkins_home:/var/jenkins_home jenkins/jenkins:lts

##### Explanation of the command:
##### 1. docker run -d: This runs the Jenkins container in detached mode (in the background).
##### 2. --name jenkins: Assigns the name jenkins to the container for easier management.
##### 3. -p 8080:8080: Maps port 8080 on your host machine to port 8080 in the container.
#####     Jenkins’ web UI will be accessible on port 8080.
#####4.  -p 50000:50000: Maps port 50000 for Jenkins agents to communicate with the Jenkins master.
##### 5. --volume jenkins_home:/var/jenkins_home
#####   This mounts a persistent volume to store Jenkins data (e.g., job configurations, plugins, and build history). The volume is named jenkins_home.
#####6. jenkins/jenkins:lts: The Docker image you're using for the Jenkins container (LTS version).

##### Unlock Jenkins
##### When we first access Jenkins, it will ask for an unlock key. 
##### To find this key, we need to run the following command to get the container’s logs:
##### docker logs jenkins

#### Manage Jenkins (Start/Stop)
##### Start Jenkins: If you stop the Jenkins container, you can restart it using: docker start jenkins
##### Stop Jenkins: To stop the container, run: docker stop jenkins
##### Remove Jenkins container: docker rm jenkins
##### To view Jenkins logs for debugging purposes, use: docker logs jenkins

#### Jenkins Pipeline for Docker Image Automation
##### This Jenkins pipeline automates the process of building, tagging, pushing, deploying, and testing a Docker image from a Git repository. The pipeline is designed to be flexible by using parameterized inputs, making it easy to customize the build and deployment process.

#### Pipeline Structure
##### The pipeline consists of the following key components:

##### 1. Agent Definition:
##### pipeline {
#####    agent any
##### Uses agent any to execute the pipeline on any available Jenkins agent.

##### 2. Parameterized Inputs:
##### parameters {
#####    string(name: 'BRANCH', description: 'Branch to build')
#####    string(name: 'GIT_URL', description: 'Git repository URL')
#####    string(name: 'DOCKER_REGISTRY', description: 'Docker registry URL')
#####    string(name: 'DOCKER_IMAGE', description: 'Docker image name')
#####    string(name: 'CONTAINER_NAME', description: 'Docker container name')
##### }
##### Uses the parameters block to allow users to input the following values:

##### BRANCH: Git branch to be cloned.

##### GIT_URL: URL of the Git repository.

##### DOCKER_REGISTRY: Docker registry where the image will be pushed.

##### DOCKER_IMAGE: Name of the Docker image to be created.

##### CONTAINER_NAME: Name of the Docker container when running the image.

##### This flexible approach avoids hardcoding values, promoting reusability.

##### 3. Stages:
##### The pipeline is divided into four primary stages:

##### a. Clone Repository:
##### stage('Clone Repository') {
#####    steps {
#####        script {
 #####          echo "Cloning repository from ${GIT_URL} on branch ${BRANCH}"
 #####           git branch: "${BRANCH}", url: "${GIT_URL}"
 #####       }
#####    }
##### }
##### Clones the specified branch from the given Git repository.

##### b. Build and Tag Docker Image:
##### stage('Build and Tag Docker Image') {
#####    steps {
#####        script {
#####            echo "Building Docker image ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
 #####           sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE} ."
 #####       }
#####    }
##### }
##### Uses docker build to create a Docker image and tag it using the specified registry and image name.

##### c. Push Docker Image:
##### stage('Push Docker Image') {
#####    steps {
#####        script {
#####            echo "Pushing Docker image ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
#####            sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
#####        }
#####    }
##### }
##### Pushes the built image to the specified Docker registry.

##### Optionally, Docker login can be performed (commented out for security).

##### d. Deploy and Test Docker Image:
##### stage('Deploy and Test Docker Image') {
#####    steps {
#####        script {
#####            echo "Running Docker image locally to verify"
#####            sh "docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
#####            sh "docker stop ${params.CONTAINER_NAME} || true"
 #####           sh "docker rm ${params.CONTAINER_NAME} || true"
#####            sh "docker run -d -p 3000:3000 --name ${params.CONTAINER_NAME} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}"
 #####           sh "docker ps"
#####        }
#####    }
##### }
##### Deploys the image locally to verify successful creation.

##### Stops and removes any existing container with the same name to avoid conflicts.

##### Runs the new container and checks the running containers list.

##### 4. Post Actions:
##### post {
#####    always {
#####        echo 'Pipeline execution completed.'
#####    }
#####    failure {
#####        echo 'Pipeline execution failed!'
#####    }
##### }
##### Ensures that completion or failure messages are logged after pipeline execution.

#### How to Run the Pipeline via SCM in Jenkins:
##### Setup:
##### 1. Make sure your GitHub repository contains the Jenkinsfile in the root directory.
##### 2. The Jenkinsfile should be present in the dev-branch or main branch.

#### Jenkins Configuration:
##### 1. Create a new Pipeline job in Jenkins.
##### 2. Under Pipeline settings, select Pipeline script from SCM.
##### 3. Choose Git as the SCM type.
##### 4. Provide the Repository URL from your GitHub repository.
##### 5. Set the Branch Specifier to the desired branch (e.g., */dev-branch or */main).
##### 6. Jenkins will automatically pull the Jenkinsfile from the specified branch when triggered.

##### Execution:
##### 1. Once the pipeline is configured, Jenkins will automatically clone the repository and run the pipeline script as defined in the Jenkinsfile.
##### 2. You can manually trigger the pipeline from the Jenkins dashboard or set up a webhook for automatic triggers.

##### Why Use SCM for Jenkins Pipeline:
##### 1. Automatic Updates: Any updates to the Jenkinsfile in the GitHub branch will be automatically picked up in subsequent builds.
##### 2. Version Control: Keeps track of pipeline changes along with code changes.
##### 3. Consistency: Ensures that the same pipeline script is used across different environments when switching branches.

##### Potential error during Jenkins pipeline build: 
##### "Building Docker image localhost:5000/node-express-app
##### [Pipeline] sh + docker build -t localhost:5000/node-express-app .
##### /var/jenkins_home/workspace/Test Project@tmp/durable-4a91558e/script.sh.copy: 1: docker: not found"

#### How to resolve if we face this error?
##### Explanation: 
##### 1. Ensure Docker is Installed on the Host Machine.
#####   Run the following command on the host machine to check if Docker is installed:
#####   docker --version
##### 2. Test the Docker Command Inside the Container
#####   To further debug, we need to enter the container's shell and manually check if Docker is available and configured properly.
#####   Run: docker exec -it <container_name_or_id> /bin/bash
#####   Then, inside the container, try running: docker --version
##### 3. Install Docker Inside the Jenkins Container.
#####   Manually install Docker inside the Jenkins container by running the following commands:
#####   apt-get update
#####   apt-get install -y docker.io
#####   After installing Docker, check the version: docker --version
##### 4. Verify Docker Socket to ensure that the Docker socket is correctly mounted from the host system to the Jenkins container.
#####   This is necessary for Jenkins to communicate with the Docker daemon 
 #####  running on the host. Run the following command inside the Jenkins container: docker ps
