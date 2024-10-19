## 🐍 DevOps Setup for SemiColon Registration System - Backend

This section describes the DevOps processes used for the SemiColon Registration System, detailing Docker configurations, Kubernetes deployments, and testing environments.

### 🎥  Demo 🎥
[Demo video and presentation](https://drive.google.com/drive/u/1/folders/1c-elELzTuevvdp616Tb47Q6NAe5uUY5t)


### ⚙️  Docker Setup ⚙️

The backend project is containerized using Docker, with separate Dockerfiles and Docker Compose configurations for development, testing, and production environments.

#### 🐳 Docker Compose

1. **docker-compose.yml** (Production)
    - **Services**:
      - `mongo`: A MongoDB instance using the `bitnami/mongodb:5.0` image.
      - `backend`: The main backend application running in a Node.js container.
    - **Health Checks**: Configured for MongoDB using `mongosh` to ensure the service is running properly.
    - **Backend Features**:
      - Ports exposed: `3000`
      - Command: `npm run deploy-linux`
      - Depends on the MongoDB service to be healthy.
    - **Environment Variables**:
      - `DEV_DB_URL`, `PROD_DB_URL`, `TEST_DB_URL`: Database URLs for different environments.
      - `SESSION_SECRET` and `PROD_SESSION_SECRET`: Secrets used for session management.

2. **docker-compose-testing.yml** (Testing)
    - **Services**:
      - `mongo`: Similar to production but focused on testing.
      - `test`: Executes the unit and integration tests using Jest, leveraging the `semicolon-backend:v1-base` Docker image.
    - **Command**: `npm run test`
    - **Environment Variables**: Similar to the production setup but pointed to the test database.

#### 🐳 Dockerfiles

1. **Dockerfile**:
    - **Stages**:
      - **Build Stage**: Uses `node:22-alpine` as the base image, installs dependencies, and builds the application.
      - **Production Stage**: Copies over the build artifacts and installs only the production dependencies.
    - **Health Check**: Configured to verify the health of the app via an HTTP request to `localhost:$PORT`.
    - **Exposed Port**: `3000`
    - **Final Command**: Runs the app using `npm run deploy-linux`.

---

### ⚙️ Kubernetes Setup ⚙️ 

The Kubernetes configuration includes deployments, ConfigMaps, and Ingress rules for managing both the backend application and MongoDB.

1. **🤔 configmap.yml**:
    - Stores environment-specific variables, such as the database URLs and application port.
    - Example:
      ```yaml
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: semicolon-backend-config
      data:
        PORT: '3000'
        NODE_ENV: 'production'
        DEV_DB_URL: 'mongodb://semicolon-backend-db-svc:27017/semicolon-dev?directConnection=true'
        TEST_DB_URL: 'mongodb://semicolon-backend-db-svc:27017/semicolon-test?directConnection=true'
        PROD_DB_URL: 'mongodb://semicolon-backend-db-svc:27017/semicolon-prod?directConnection=true'
      ```

2. **🤔 app-deployment.yml** (Backend Application):
    - Defines the deployment for the backend app.
    - **Replicas**: 1 instance for now, can be scaled.
    - **Init Containers**: Used to run tests before the main application starts.
    - **Environment Variables**: Pulled from the `ConfigMap` and `Secret`.

3. **🤔 app-deployment.yml** (MongoDB):
    - Defines the deployment for MongoDB using the `bitnami/mongodb:5.0` image.
    - Configured with a primary replica and emptyDir volumes for persistence.

4. **🤔 app-ingress.yml**:
    - Configures an NGINX Ingress for exposing the backend API to the outside world.
    - **Annotations**: SSL redirect is disabled for this setup.
    - **Rules**: Maps the host `semicolon-backend.com` to the service.

---

## 🔧 CI/CD Pipeline 🔧


The Jenkins pipeline automates the testing, building, and provisioning of infrastructure for the SemiColon Registration System. The stages include running tests, **building** Docker images, provisioning infrastructure with **Terraform**, and deploying configurations using **Ansible**.



### Jenkinsfile Overview

1. **❗ Preparation**:
   - Clones the repository from GitHub (`main` branch) to the Jenkins workspace.

2. **❗ Test**:
   - Runs tests using Docker Compose with the `docker-compose-testing.yml` file.
   - Tears down any existing containers and brings up new ones to ensure a fresh test environment.
   
   ```groovy
   sh "docker compose -f docker-compose-testing.yml down --remove-orphans"
   sh "docker compose -f docker-compose-testing.yml up -d --build"
   ```

3. **❗ Build**:
   - Builds a Docker image for the backend.
   - Uses Jenkins credentials to log into Docker Hub and pushes the built image tagged with the build number.
   
   ```groovy
   def imageName = "hassanbahnasy/semi-colon:${BUILD_NUMBER}"
   sh "docker build . -t ${imageName}"
   sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
   sh "docker push ${imageName}"
   ```

4. **❗ Provision Infrastructure**:
   - Uses Terraform to provision infrastructure on Azure.
   - Jenkins credentials are used for Azure authentication.
   - SSH agent is used for secure remote execution of Terraform commands.
   
   ```groovy
   withEnv(["TF_VAR_client_id=${AZURE_CLIENT_ID}", "TF_VAR_client_secret=${AZURE_CLIENT_SECRET}", "TF_VAR_tenant_id=${AZURE_TENANT_ID}", "TF_VAR_subscription_id=${AZURE_SUBSCRIPTION_ID}"]) {
       sshagent(['bahnasy']) { 
           sh 'cd terraform && terraform init'
           sh 'cd terraform && terraform apply -auto-approve'
       }
   }
   ```

5. **❗ Get Public IP**:
   - After provisioning, the pipeline fetches the public IP address of the deployed infrastructure from the Terraform output.
   - This IP is stored as an environment variable for later stages.

   ```groovy
   def publicIP = sh(script: 'cd terraform && terraform output -json public_ip_address', returnStdout: true).trim()
   ```

6. **❗ Run Ansible Playbook**:
   - Executes an Ansible playbook to configure the deployed infrastructure, using the public IP obtained from the Terraform stage.
   - Jenkins securely provides SSH credentials for connecting to the remote machine.

   ```groovy
   withCredentials([sshUserPrivateKey(credentialsId: 'ansible', keyFileVariable: 'SSH_KEY')]) {
       sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user azureuser --private-key $SSH_KEY -e \"ansible_ssh_common_args='-o StrictHostKeyChecking=no'\""
   }
   ```

### 📢 Post-Build Actions

After the pipeline completes, notifications are sent to a Slack channel based on the success or failure of the job:

- **Success**: Sends a green notification with a success message.
- **Failure**: Sends a red notification with a failure message.

```groovy
post {
    success {
        slackSend(channel: "depi", color: '#00FF00', message: "Succeeded: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
    }
    failure {
        slackSend(channel: "depi", color: '#FF0000', message: "Failed: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
    }
}
```




# ♾️ Terraform ♾️ 


#### Key Files
- **`providers.tf`**: Configures the Azure provider to authenticate using a Service Principal (SP). It requires environment variables for the client ID, client secret, tenant ID, and subscription ID.
  
- **`variables.tf`**: Defines variables used in the provider configuration for the client ID, secret, tenant, and subscription details. Additionally, a local block defines the resource group and location.

- **`virtual_machine.tf`**:
  - **Resource Group**: Creates the Azure resource group `semi-colon-vm`.
  - **Virtual Network & Subnet**: Defines the network and subnet for the VM.
  - **Public IP**: Allocates a static public IP for the VM.
  - **Network Security Group (NSG)**: Allows inbound SSH connections on port 22 and app traffic on port 3000.
  - **Network Interface**: Attaches the public IP and subnet to the virtual machine.
  - **Virtual Machine (VM)**: Provisions a Linux Ubuntu VM with SSH key authentication using a key stored in Jenkins.
  
- **`output.tf`**: Exports the public IP address of the VM.



# 🔧 Ansible 🔧

#### Variables:
- `target_host`: The target host where the playbook will be executed (i.e., the public IP of the Azure virtual machine).
- `remote_user`: The user used to connect to the VM (in this case, `azureuser`).

#### Playbook Breakdown:

1. **Updating apt package manager**  
   **Task Name:** `Update apt packages`
   - **Description:** This task ensures that the system's package index is up to date, which is critical before installing new packages. It forces an update and sets a cache validity of 3600 seconds (1 hour) to minimize repeated updates.
   ```yaml
   apt:
     update_cache: yes
     force_apt_get: yes
     cache_valid_time: 3600
   ```

2. **Installing Docker dependencies**  
   **Task Name:** `Install Docker dependencies`
   - **Description:** This task installs the necessary system dependencies required to set up Docker. It installs packages for handling HTTP requests, certificate management, and adding new repositories.
   ```yaml
   apt:
     name: 
       - apt-transport-https
       - ca-certificates
       - curl
       - software-properties-common
     state: present
   ```

3. **Adding Docker GPG Key**  
   **Task Name:** `Add Docker GPG key`
   - **Description:** Before installing Docker from the official repository, this step adds the Docker GPG key to ensure that the packages installed from Docker’s repository are trusted.
   ```yaml
   apt_key:
     url: https://download.docker.com/linux/ubuntu/gpg
     state: present
   ```

4. **Adding Docker Repository**  
   **Task Name:** `Add Docker repository`
   - **Description:** This task adds the official Docker repository for Ubuntu so that Docker packages can be installed directly from it. This ensures that you get the latest stable version.
   ```yaml
   apt_repository:
     repo: deb https://download.docker.com/linux/ubuntu focal stable
     state: present
   ```

5. **Installing Docker**  
   **Task Name:** `Install Docker`
   - **Description:** This task installs Docker CE (Community Edition) from the repository we added earlier. It also ensures that the package cache is updated, so the system knows about the new repository packages.
   ```yaml
   apt:
     name: docker-ce
     state: present
     update_cache: yes
   ```

6. **Enabling and Starting Docker Service**  
   **Task Name:** `Start and enable Docker service`
   - **Description:** This task ensures Docker is started and will automatically start on system boot, which is essential for managing containers continuously.
   ```yaml
   systemd:
     name: docker
     enabled: yes
     state: started
   ```

7. **Installing Docker Compose**  
   **Task Name:** `Install Docker Compose`
   - **Description:** Docker Compose is used to manage multi-container Docker applications. This task downloads the specified version of Docker Compose from GitHub and sets the correct permissions for the binary.
   ```yaml
   get_url:
     url: "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-{{ ansible_system }}-{{ ansible_architecture }}"
     dest: /usr/local/bin/docker-compose
     mode: '0755'
   ```

8. **Cloning the Application Repository**  
   **Task Name:** `Clone the application repository`
   - **Description:** This task clones the Semi-Colon backend repository from GitHub into the `/home/azureuser/semi-colon-app` directory on the target machine. This ensures the latest version of the application is deployed.
   ```yaml
   git:
     repo: 'https://github.com/Bahnasy2001/semi-colon-pipeline.git'
     dest: /home/azureuser/semi-colon-app
     version: main
   ```

9. **Running Docker Compose**  
   **Task Name:** `Run Docker Compose for the application`
   - **Description:** This task navigates to the application directory and runs Docker Compose to build and start the backend application. It first tears down any previous containers (to avoid orphaned containers) and then builds and starts new ones using the latest code from the repository.
   ```yaml
   shell: |
     docker-compose down --remove-orphans
     docker-compose up -d --build
   args:
     chdir: /home/azureuser/semi-colon-app
   ```