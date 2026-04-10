pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }
    
    environment {
// Docker Hub credentials
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        IMAGE_NAME = "olawaledevops/my-app"  // Your Docker Hub username
        KUBECTL_HOST = "3.218.207.3"
        SSH_USER = "ec2-user"  // Your EC2 username
        SSH_CREDENTIALS_ID = "ec2-ssh-key"  // Your SSH credential ID
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub'
                checkout scm
            }
        }
        
        stage('Debug - Verify Structure') {
            steps {
                echo 'Verifying repository structure...'
                sh '''
                    echo "Current directory:"
                    pwd
                    echo "Listing root directory:"
                    ls -la
                    echo "Webapp directory contents:"
                    ls -la webapp/
                    echo "Src directory contents:"
                    ls -la webapp/src/
                    echo "Dockerfile content:"
                    cat webapp/Dockerfile
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image from webapp directory...'
                script {
                    // Build using Dockerfile in ./webapp
                    sh "docker build -t ${IMAGE_TAG} ./webapp"
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${IMAGE_TAG}"
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                echo 'Deploying to EKS cluster...'
                script {
                    # Update kubeconfig
                    sh "aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${CLUSTER_NAME}"
                    
                    # Apply Kubernetes deployment (if deployment.yaml exists)
                    sh "kubectl apply -f deployment.yaml"
                    
                    # Update image in deployment (adjust deployment name as needed)
                    sh "kubectl set image deployment/webapp webapp=${IMAGE_TAG} --record"
                    
                    # Wait for rollout
                    sh "kubectl rollout status deployment/webapp"
                    
                    # Verify deployment
                    sh "kubectl get nodes"
                    sh "kubectl get pods"
                    sh "kubectl get services"
                }
            }
        }
    }
    
    post {
        always {
            script {
                sh "docker logout"
                cleanWs()
            }
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}
