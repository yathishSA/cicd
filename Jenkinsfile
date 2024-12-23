pipeline {  
    agent { label ' jenkins_slave' }

    tools {
        maven 'maven3'
        
    }

    environment {
        ECR_REPO = '866934333672.dkr.ecr.us-east-1.amazonaws.com/jay-repo'
        IMAGE_NAME = 'app-image'
        TAG = "${env.BRANCH_NAME}-${env.BUILD_ID}"
        
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/your-org/your-repo.git'
            }
        }
        
        stage('Build Application') {
            steps {
            sh 'mvn clean package -Dmaven.test.skip=true'
            }
        }

        stage('Build Docker Image') {
    steps {
        script {
            // Specify the Dockerfile location using the -f option
            docker.build("${env.ECR_REPO}:${env.TAG}", "-f docker/Dockerfile .")
        }
    }
}


        stage('Push to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-ecr', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${env.ECR_REPO}"
                    sh "docker push ${env.ECR_REPO}:${env.TAG}"
                }
            }
            post {
                success {
                    // Send email notification after successful image push to ECR
                    emailext(
                        subject: "Jenkins Job - Docker Image Pushed to ECR Successfully",
                        body: "Hello,\n\nThe Docker image '${env.IMAGE_NAME}:${env.TAG}' has been successfully pushed to ECR.\n\nBest regards,\nJenkins",
                        recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                        to: "jap4810@gmail.com"
                    )
                }
            }
        }

        stage('Static Code Analysis - SonarQube') {
            steps {
                script {
                    withSonarQubeEnv('SonarQubeServer') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
    stage('Deploy to Environment') {
            steps {
                script {
                    def targetHost = ''
                    if (env.BRANCH_NAME == 'dev') {
                        targetHost = '<DEV-EC2-IP>'
                    } else if (env.BRANCH_NAME == 'staging') {
                        targetHost = '<STAGING-EC2-IP>'
                    } else if (env.BRANCH_NAME == 'main') {
                        targetHost = '<54.234.80.60>'
                    }
                    // Use withCredentials to securely handle the SSH key
            withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY_FILE')]){
                    sh 'chmod 600 ${SSH_KEY_FILE}'
                    sh 'ssh -t -i ${SSH_KEY_FILE} root@${targetHost} << EOF'
                    sh """#!/bin/bash
                    docker pull ${ECR_REPO}:${TAG}
                    docker stop ${IMAGE_NAME} || true
                    docker rm ${IMAGE_NAME} || true
                    docker run -d --name ${IMAGE_NAME} -p 80:80 ${ECR_REPO}:${TAG}
                    EOF
                    """
            }
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean up workspace after the build
        }
    }
}
