pipeline {
    agent any
    environment {
        // Use the Jenkins secret text credential for the client secret
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_CLIENT_ID = '8d5b517c-1fc2-4ca3-a5f4-8c0880fbe2da' 
        AZURE_TENANT_ID = '0acb909c-7263-4beb-bb28-fa1d5b663a90' 
        AZURE_SUBSCRIPTION_ID = '71d131e2-d168-45ca-9afe-06ed2ae2e20f'
    }
    stages {
        stage('preparation') {
            steps {
                // Clone the repository
                git(
                    url: 'https://github.com/MostafaAMansour/semi-colon-pipeline',
                    branch: 'main'
                )
            }
        }
        // stage('test') {
        //     steps {
        //         echo "docker compose"
        //         sh "docker compose -f docker-compose-testing.yml down --remove-orphans"
        //         sh "docker compose -f docker-compose-testing.yml up -d --build"
        //     }
        // }

        // stage('build') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'dockerhub-MostafaAMansour', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        //             script {
        //                 // Define the image name with the build number as a tag
        //                 def imageName = "mostafaamansour/semi-colon:${BUILD_NUMBER}"
                        
        //                 // Build Docker image with the unique tag
        //                 sh "docker build . -t ${imageName}"
                        
        //                 // Log in to Docker Hub
        //                 sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                        
        //                 // Push Docker image to Docker Hub
        //                 sh "docker push ${imageName}"
        //             }
        //         }
        //     }
        // }
        stage('Provision Infrastructure') {
            steps {
                script {

                    // Set Terraform environment variables
                    withEnv(["TF_VAR_client_id=${AZURE_CLIENT_ID}", "TF_VAR_client_secret=${AZURE_CLIENT_SECRET}", "TF_VAR_tenant_id=${AZURE_TENANT_ID}", "TF_VAR_subscription_id=${AZURE_SUBSCRIPTION_ID}"]) {
                        // Use sshagent to load SSH credentials
                        sshagent(['SSH-semi-colon']) { 
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
                    withCredentials([sshUserPrivateKey(credentialsId: 'SSH-semi-colon', keyFileVariable: 'SSH_SEMI_COLON')]) {
                        sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP} user_var=azureuser' --private-key $SSH_SEMI_COLON -e \"ansible_ssh_common_args='-o StrictHostKeyChecking=no'\""
                }
                    }   
            }
        }

    }
    post {
        success {
            slackSend(channel: "Jenkins", color: '#00FF00', message: "Succeeded: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
        }
        failure {
            slackSend(channel: "Jenkins", color: '#FF0000', message: "Failed: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}'")
        }
    }
}