pipeline {
    // Run on any available agent (SSH agent in Jenkins UI points to your Kubectl EC2)
    agent any

    environment {
        // Docker Hub credentials stored in Jenkins UI
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        IMAGE_NAME = "your-dockerhub-username/my-app"   // Change to your Docker Hub username
        KUBECONFIG = "/home/ubuntu/.kube/config"        // Path to kubeconfig on the agent
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10')) // Keep last 10 builds
        timeout(time: 30, unit: 'MINUTES')            // Timeout after 30 minutes
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub"
                git branch: 'main', url: 'https://github.com/yourusername/webapp-repo.git'
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
                echo "Logging in to Docker Hub and pushing image..."
                sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push $IMAGE_NAME:${BUILD_NUMBER}
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo "Updating Kubernetes deployment..."
                sh """
                    kubectl set image deployment/my-app-deployment my-app-container=$IMAGE_NAME:${BUILD_NUMBER} --kubeconfig=$KUBECONFIG
                    kubectl rollout status deployment/my-app-deployment --kubeconfig=$KUBECONFIG
                """
            }
        }

    }

    post {
        success {
            echo "Build, push, and deployment completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs for details."
        }
        always {
            echo "Logging out of Docker Hub..."
            sh 'docker logout'
        }
    }
}
