pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }
    
    environment {
        // Docker Hub credentials
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        IMAGE_NAME = "olawaledevops/my-app"
        IMAGE_TAG = "${IMAGE_NAME}:${BUILD_NUMBER}"
        
        // EC2 configuration (your instance from earlier)
        KUBECTL_HOST = "3.218.207.3"
        SSH_USER = "ec2-user"
        SSH_CREDENTIALS_ID = "ec2-ssh-key"
        
        // AWS EKS configuration
        AWS_DEFAULT_REGION = "us-east-1"
        CLUSTER_NAME = "my-eks-cluster"
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
                    ls -la Webapp/
                    echo "Src directory contents:"
                    ls -la Webapp/Src/
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image from webapp directory...'
                script {
                    sh "docker build -t ${IMAGE_TAG} ./Webapp"
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
        
        stage('Deploy to EKS via SSH') {
            steps {
                echo 'Deploying to EKS cluster from EC2 instance...'
                script {
                    // SSH to EC2 and run kubectl commands
                    sshagent([SSH_CREDENTIALS_ID]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${SSH_USER}@${KUBECTL_HOST} << 'EOF'
                                # Update kubeconfig
                                aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${CLUSTER_NAME}
                                
                                # Apply deployment
                                kubectl apply -f deployment.yaml
                                
                                # Update image
                                kubectl set image deployment/webapp webapp=${IMAGE_TAG} --record
                                
                                # Wait for rollout
                                kubectl rollout status deployment/webapp
                                
                                # Verify
                                kubectl get nodes
                                kubectl get pods
                                kubectl get services
EOF
                        """
                    }
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
