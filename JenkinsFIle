pipeline {
    agent any
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }
    environment{
        SCANNER_HOME= tool "sonar-scanner"
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', changelog: false, credentialsId: '2a74494e-0ddf-4f90-b03c-266f86a56170', url: 'https://github.com/jaiswaladi246/Ekart.git'
            }
        }
        
         stage('COMPILE') {
            steps {
                sh "mvn clean compile -DskipTests=true"
            }
        }
        
         stage('OWASP Scan') {
              steps {
                 script {
                    // Define the path to the DependencyCheck installation
                    def dependencyCheckHome = tool 'DP'
                    // Run the DependencyCheck command
                    sh "${dependencyCheckHome}/dependency-check/bin/dependency-check.sh --project 'YourProject' --scan './src' --out './dependency-check-report'"
                }
              }
        }
        
        stage('Sonarqube') {
              steps {
                 script {
                   withSonarQubeEnv('sonar-server') {
                        sh '''
                            $SCANNER_HOME/bin/sonar-scanner \
                            -Dsonar.projectName="Ekart" \
                            -Dsonar.java.binaries="." \
                            -Dsonar.projectKey="Ekart"
                        '''
                    }

                }
              }
        }
        
        stage('Build') {
            steps {
                sh "mvn clean package -DskipTests=true"
            }
        }
        
         stage('Docer Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'cc060999-7979-4a99-a546-3ff2001d59cc', url: 'https://index.docker.io/v1/') {
                        sh "docker build -t ekart -f docker/Dockerfile ."
                        sh "docker tag ekart sasha444/ekart:latest"
                        sh "docker push sasha444/ekart:latest"
                    }
                }
            }
        }
    }
}
