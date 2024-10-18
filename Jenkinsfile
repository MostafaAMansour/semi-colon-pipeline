pipeline {
    agent any
    environment {
        // Use the Jenkins secret text credential for the client secret
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_CLIENT_ID = '1f81f02e-3e45-4843-bb24-c3bfa7abc2ed' 
        AZURE_TENANT_ID = '35881919-2ba8-413a-992c-e6ae37259fc1' 
        AZURE_SUBSCRIPTION_ID = '2876b6d2-2be8-44cb-8742-6acd23ed4f18'
        STATE_DIR = "/var/lib/jenkins/terraform_state" // Specify a shared directory
    }
    stages {
        stage('preparation') {
            steps {
                // Clone the repository
                git(
                    url: 'https://github.com/Bahnasy2001/semi-colon-pipeline.git',
                    branch: 'main'
                )
            }
        }
        stage('test') {
            steps {
                echo "docker compose"
                sh "docker compose -f docker-compose-testing.yml down --remove-orphans"
                sh "docker compose -f docker-compose-testing.yml up -d --build"
            }
        }
        // stage('build') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        //             // // Build Docker image
        //             // sh 'docker build . -t hassanbahnasy/semi-colon'
                    
        //             // // Log in to Docker Hub
        //             // sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                    
        //             // // Push Docker image to Docker Hub
        //             // sh 'docker push hassanbahnasy/semi-colon'
                    
        //         }
        //     }
        // }
        stage('build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    script {
                        // Define the image name with the build number as a tag
                        def imageName = "hassanbahnasy/semi-colon:${BUILD_NUMBER}"
                        
                        // Build Docker image with the unique tag
                        sh "docker build . -t ${imageName}"
                        
                        // Log in to Docker Hub
                        sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                        
                        // Push Docker image to Docker Hub
                        sh "docker push ${imageName}"
                    }
                }
            }
        }
        stage('Provision Infrastructure') {
            steps {
                script {
                    // sh "mkdir -p ${STATE_DIR}"
                    // sh "cp -R terraform/* ${STATE_DIR}/"
                    // Set Terraform environment variables
                    withEnv(["TF_VAR_client_id=${AZURE_CLIENT_ID}", "TF_VAR_client_secret=${AZURE_CLIENT_SECRET}", "TF_VAR_tenant_id=${AZURE_TENANT_ID}", "TF_VAR_subscription_id=${AZURE_SUBSCRIPTION_ID}"]) {
                        // Use sshagent to load SSH credentials
                        sshagent(['bahnasy']) { 
                            // sh "cd ${STATE_DIR} && terraform init"
                            // sh "cd ${STATE_DIR} && terraform apply -auto-approve"
                            sh 'cd terraform && terraform init'
                            sh 'cd terraform && terraform apply -auto-approve'
                        }
                    }
                }
            }
        }
        stage('Get Public IP') {
            steps {
                script {
                    // Fetch the public IP address
                    def publicIP = sh(script: 'cd terraform && terraform output -json public_ip_address', returnStdout: true).trim()
                    echo "Public IP Address: ${publicIP}"
                    // Set the public IP as an environment variable for subsequent stages
                    env.PUBLIC_IP = publicIP
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ansible', keyFileVariable: 'SSH_KEY')]) {
                        // Run Ansible playbook, using the public IP
                        // sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user azureuser --private-key $SSH_KEY"
                    // sh "chmod 400 id_rsa"
                    // sh "ansible-playbook -i 172.167.142.78, semi-colon.yml --extra-vars 'target_host=172.167.142.78' --user azureuser --private-key './id_rsa' "
                        sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user azureuser --private-key $SSH_KEY -e \"ansible_ssh_common_args='-o StrictHostKeyChecking=no'\""
                }
                    }   
                // ansible-playbook -i 172.167.142.78, semi-colon.yml --extra-vars 'target_host=172.167.142.78' --user azureuser --private-key "~/.ssh/id_rsa"
            }
        }
        // stage('cd') {
        //     steps {
        //         echo "docker compose"
        //         sh "docker compose -f docker-compose.yml down --remove-orphans"
        //         sh "docker compose -f docker-compose.yml up -d --build"
        //     }
        // }
    }
    post {
        success {
            slackSend(channel: "depi", color: '#00FF00', message: "Succeeded: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
        }
        failure {
            slackSend(channel: "depi", color: '#FF0000', message: "Failed: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
        }
    }
}