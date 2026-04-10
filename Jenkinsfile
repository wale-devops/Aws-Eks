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
                    echo "Checking for deployment.yaml:"
                    ls -la deployment.yaml || echo "deployment.yaml not found in root"
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
                    sshagent([SSH_CREDENTIALS_ID]) {
                        sh """
                            # Copy deployment files to EC2 instance
                            echo "Copying deployment.yaml to EC2 instance..."
                            scp -o StrictHostKeyChecking=no deployment.yaml ${SSH_USER}@${KUBECTL_HOST}:/tmp/deployment.yaml
                            
                            ssh -o StrictHostKeyChecking=no ${SSH_USER}@${KUBECTL_HOST} << 'EOF'
                                echo "Updating kubeconfig for EKS cluster..."
                                aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${CLUSTER_NAME}
                                
                                echo "Applying Kubernetes deployment..."
                                kubectl apply -f /tmp/deployment.yaml
                                
                                echo "Updating deployment image to ${IMAGE_TAG}..."
                                kubectl set image deployment/webapp webapp=${IMAGE_TAG} --record
                                
                                echo "Waiting for rollout to complete..."
                                kubectl rollout status deployment/webapp --timeout=5m
                                
                                echo "Verifying deployment..."
                                echo "Nodes:"
                                kubectl get nodes
                                echo ""
                                echo "Pods:"
                                kubectl get pods
                                echo ""
                                echo "Services:"
                                kubectl get services
                                echo ""
                                echo "Deployment status:"
                                kubectl get deployment webapp
                                
                                echo "Cleaning up temporary files..."
                                rm -f /tmp/deployment.yaml
                                
                                echo "Deployment completed successfully!"
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
