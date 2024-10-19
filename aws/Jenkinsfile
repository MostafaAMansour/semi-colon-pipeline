// pipeline {
//     agent any
//     environment {
//         // Use the Jenkins secret text credential for AWS
//         AWS_ACCESS_KEY_ID = credentials('aws_access_key_id') // Reference your AWS Access Key ID
//         AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key') // Reference your AWS Secret Access Key
     
//     }    
//     stages {
//         stage('Preparation') {
//             steps {
//                 script {
//                     slackSend(channel: 'devops', message: "Starting the pipeline for ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER}")
//                 }
//                 // Checkout the repository from GitHub
//                 git(
//                     url: 'https://github.com/mostafa-7ussein/semicolon',
//                     branch: 'main'
//                 )
//             }
//         }
//         stage('Test') {
//             steps {
//                 echo "Running Docker Compose tests"
//                 // Clean up any previous instances and start new ones
//                 sh "docker compose -f docker-compose-testing.yml down --remove-orphans"
//                 sh "docker compose -f docker-compose-testing.yml up -d --build"
//             }
//         }
//         stage('Build and Push Docker Image') {
//             steps {
//                 script {
//                     // Define the image name and tag using Git commit hash
//                     def imageTag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
//                     def imageName = "mostafahu/semicolon-backend:${imageTag}"
                    
//                     // Build the Docker image
//                     sh "docker build . -t ${imageName}"

//                     // Check if the image already exists on Docker Hub
//                     def imageExists = sh(script: "docker manifest inspect ${imageName}", returnStatus: true)

//                     // Use Jenkins credentials for Docker Hub login
//                     withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
//                         if (imageExists != 0) {
//                             // Log in to Docker Hub
//                             sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'

//                             // Push Docker image to Docker Hub
//                             sh "docker push ${imageName}"

//                             // Tag as 'latest' and push
//                             sh "docker tag ${imageName} mostafahu/semicolon-backend:latest"
//                             sh "docker push mostafahu/semicolon-backend:latest"

//                             echo "Docker image ${imageName} pushed successfully."
//                         } else {
//                             echo "No changes detected, Docker image ${imageName} already exists. Skipping push."
//                         }
//                     }
//                 }
//             }
//         }













// // stage('Provision Infrastructure') {
// //             steps {
// //                 script {
// //                     // Set AWS environment variables (ensure you have these credentials set in Jenkins)
// //                     withEnv(["AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" ]) {
// //                         echo ${AWS_ACCESS_KEY_ID}
// //                         echo ${AWS_SECRET_ACCESS_KEY}
// //                         // Use sshagent to load SSH credentials (if needed)
// //                         sshagent(['ssh-credentials-id']) {
// //                             // Initialize Terraform and apply
// //                             sh 'cd terraform && terraform init'
// //                             sh 'cd terraform && terraform apply -auto-approve'
// //                         }
// //                     }
// //                 }
// //             }
// //         }

// stage('Provision Infrastructure') {
//     steps {
//         script {
//             withEnv(["AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"]) {
//                 echo "Provisioning infrastructure with Terraform"
//                 sshagent(['ssh-credentials-id']) {
//                     try {
//                         sh 'cd terraform && terraform init'
//                         sh 'cd terraform && terraform apply -auto-approve'
//                     } catch (Exception e) {
//                         echo "Terraform command failed: ${e.message}"
//                         currentBuild.result = 'FAILURE'
//                         error("Aborting pipeline due to Terraform failure.")
//                     }
//                 }
//             }
//         }
//     }
// }

//         stage('Get Public IP') {
//             steps {
//                 script {
//                     // Fetch the public IP address
//                     def publicIP = sh(script: 'cd terraform && terraform output -json ec2_public_ip ', returnStdout: true).trim()
//                     echo "Public IP Address: ${publicIP}"
//                     // Set the public IP as an environment variable for subsequent stages
//                     env.PUBLIC_IP = publicIP
//                 }
//             }
//         }
    


//                 stage('Run Ansible Playbook') {
//             steps {
//                 script {
//                     withCredentials([sshUserPrivateKey(credentialsId: 'ssh-credentials-id', keyFileVariable: 'SSH_KEY')]) {
//                         // Run Ansible playbook, using the public IP
//                         // sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user azureuser --private-key $SSH_KEY"
//                     // sh "chmod 400 id_rsa"
//                     // sh "ansible-playbook -i 172.167.142.78, semi-colon.yml --extra-vars 'target_host=172.167.142.78' --user azureuser --private-key './id_rsa' "
//                         sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user ubuntu --private-key $SSH_KEY -e \"ansible_ssh_common_args='-o StrictHostKeyChecking=no'\""
//                 }
//                     }   
//                 // ansible-playbook -i 172.167.142.78, semi-colon.yml --extra-vars 'target_host=172.167.142.78' --user azureuser --private-key "~/.ssh/id_rsa"
//             }
//         }


//     }
//     post {
//         success {
//             script {
//                 slackSend(channel: '#devops',color: '#00FF00', message: "Succeeded  ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} succeeded!")
//             }
//         }
//         failure {
//             script {
//                 slackSend(channel: '#devops', message: "Pipeline ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} failed!")
//             }
//         }
//         always {
//             script {
//                 slackSend(channel: '#devops', color: '#FF0000', message: "Failed: ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} finished.")
//             }
//         }
//     }
// }
pipeline {
    agent any
    environment {
        // Use the Jenkins secret text credential for AWS
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id') // Reference your AWS Access Key ID
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key') // Reference your AWS Secret Access Key
    }
    stages {
        stage('Preparation') {
            steps {
                script {
                    slackSend(channel: 'devops', message: "Starting the pipeline for ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER}")
                }
                // Checkout the repository from GitHub
                git(
                    url: 'https://github.com/mostafa-7ussein/semicolon',
                    branch: 'main'
                )
            }
        }
        stage('Test') {
            steps {
                echo "Running Docker Compose tests"
                // Clean up any previous instances and start new ones
                sh "docker compose -f docker-compose-testing.yml down --remove-orphans"
                sh "docker compose -f docker-compose-testing.yml up -d --build"
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Define the image name and tag using Git commit hash
                    def imageTag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "mostafahu/semicolon-backend:${imageTag}"
                    
                    // Build the Docker image
                    sh "docker build . -t ${imageName}"

                    // Check if the image already exists on Docker Hub
                    def imageExists = sh(script: "docker manifest inspect ${imageName}", returnStatus: true)

                    // Use Jenkins credentials for Docker Hub login
                    withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        if (imageExists != 0) {
                            // Log in to Docker Hub
                            sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'

                            // Push Docker image to Docker Hub
                            sh "docker push ${imageName}"

                            // Tag as 'latest' and push
                            sh "docker tag ${imageName} mostafahu/semicolon-backend:latest"
                            sh "docker push mostafahu/semicolon-backend:latest"

                            echo "Docker image ${imageName} pushed successfully."
                        } else {
                            echo "No changes detected, Docker image ${imageName} already exists. Skipping push."
                        }
                    }
                }
            }
        } 
        stage('Provision Infrastructure') {
            steps {
                script {
                    // Set AWS environment variables (ensure you have these credentials set in Jenkins)
                    // withEnv(["AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"]) {
                    withEnv(["TF_VAR_aws_access_key=${AWS_ACCESS_KEY_ID}", "TF_VAR_aws_secret_key=${AWS_SECRET_ACCESS_KEY}"]) {                        
                        echo "Provisioning infrastructure with Terraform"
                        sshagent(['ssh-credentials-id']) {
                            // Initialize Terraform and apply
                            try {
                                sh 'cd terraform && terraform init'
                                sh 'cd terraform && terraform apply -auto-approve'
                            } catch (Exception e) {
                                echo "Terraform command failed: ${e.message}"
                                currentBuild.result = 'FAILURE'
                                error("Aborting pipeline due to Terraform failure.")
                            }
                        }
                    }
                }
            }
        }
        stage('Get Public IP') {
            steps {
                script {
                    // Fetch the public IP address
                    def publicIP = sh(script: 'cd terraform && terraform output -json ec2_public_ip', returnStdout: true).trim()
                    echo "Public IP Address: ${publicIP}"
                    // Set the public IP as an environment variable for subsequent stages
                    env.PUBLIC_IP = publicIP
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                // script {
                //     withCredentials([sshUserPrivateKey(credentialsId: 'ssh-credentials-id', keyFileVariable: 'SSH_KEY')]) {
                //         // Run Ansible playbook, using the public IP
                //         sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user ubuntu --private-key $SSH_KEY -e \"ansible_ssh_common_args='-o StrictHostKeyChecking=no'\""
                //     }
                // }

                script {
                      withCredentials([sshUserPrivateKey(credentialsId: 'ssh-credentials-id', keyFileVariable: 'SSH_KEY')]) {
                // Run Ansible playbook, using the public IP
                        sh "ansible-playbook -i ${env.PUBLIC_IP}, semi-colon.yml --extra-vars 'target_host=${env.PUBLIC_IP}' --user ubuntu --private-key $SSH_KEY -e \"ansible_ssh_common_args='-o StrictHostKeyChecking=no'\""
            }
        }
            }
        }
    }
    post {
        success {
            script {
                slackSend(channel: '#devops', color: '#00FF00', message: "Succeeded  ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} succeeded!")
            }
        }
        failure {
            script {
                slackSend(channel: '#devops', message: "Pipeline ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} failed!")
            }
        }
        always {
            script {
                slackSend(channel: '#devops', color: '#FF0000', message: "Finished: ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER}.")
            }
        }
    }
}
