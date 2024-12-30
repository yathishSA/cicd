pipeline {   
    agent { label 'Slave1' }

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

        stage('Container Security Scan - Trivy') {
            steps {
                script {
                    sh 'aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 866934333672.dkr.ecr.us-east-1.amazonaws.com'
                    sh 'sudo usermod -aG docker root'
                    sh "trivy image 866934333672.dkr.ecr.us-east-1.amazonaws.com/jay-repo:main-9"
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
                    // Check the branch name and set the appropriate target
                    def targetHost = ''
                    if (env.BRANCH_NAME == 'dev') {
                        targetHost = 'dev-server'  // Define the name or address for the dev server if needed
                    } else if (env.BRANCH_NAME == 'staging') {
                        targetHost = 'staging-server'  // Define the name or address for staging
                    } else if (env.BRANCH_NAME == 'main') {
                        targetHost = 'production-server'  // Define the production server address
                    }
                    
                    // Run deployment commands directly on the same agent (slave) server
                    echo "Deploying to $targetHost"
                    sh """
                        echo "Pulling Docker image..."
                        docker pull ${ECR_REPO}:${TAG}
                        echo "Stopping existing container..."
                        docker stop ${IMAGE_NAME} || true
                        docker rm ${IMAGE_NAME} || true
                        echo "Running new container..."
                        docker run -d --name ${IMAGE_NAME} -p 80:80 ${ECR_REPO}:${TAG}
                        echo "Deployment completed"
                    """
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
