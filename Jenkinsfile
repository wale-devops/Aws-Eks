pipeline {
    agent any

    environment {
        // Docker Hub credentials
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        IMAGE_NAME = "olawaledevops/my-app"  // Your Docker Hub username
        KUBECTL_HOST = "3.218.207.3"
        SSH_USER = "ec2-user"  // Your EC2 username
        SSH_CREDENTIALS_ID = "ec2-ssh-key"  // Your SSH credential ID
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub"
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t $IMAGE_NAME:${BUILD_NUMBER} .'
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing to Docker Hub..."
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push $IMAGE_NAME:${BUILD_NUMBER}
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo "Deploying to EKS via SSH to kubectl EC2 (44.192.5.50)..."
                sshagent(credentials: [SSH_CREDENTIALS_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SSH_USER}@${KUBECTL_HOST} \
                        "kubectl set image deployment/my-app-deployment \
                        my-app-container=${IMAGE_NAME}:${BUILD_NUMBER}"
                    """
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SSH_USER}@${KUBECTL_HOST} \
                        "kubectl rollout status deployment/my-app-deployment"
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs."
        }
        always {
            sh 'docker logout'
        }
    }
}
