pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        IMAGE_NAME = "olawaledevops/my-app"
        IMAGE_TAG = "${IMAGE_NAME}:${BUILD_NUMBER}"

        SSH_USER = "ec2-user"
        SSH_CREDENTIALS_ID = "ec2-ssh-key"

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

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
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
                    sh "docker tag ${IMAGE_TAG} ${IMAGE_NAME}:latest"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Get Kubectl Host') {
            steps {
                script {
                    KUBECTL_HOST = sh(
                        script: "aws ssm get-parameter --name /eks/kubectl-ip --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text",
                        returnStdout: true
                    ).trim()
                    echo "Kubectl host: ${KUBECTL_HOST}"
                }
            }
        }

        stage('Deploy to EKS via SSH') {
            steps {
                echo 'Deploying to EKS cluster...'
                script {
                    sh "sed -i 's|${IMAGE_NAME}:latest|${IMAGE_TAG}|g' deployment.yaml"

                    sshagent([SSH_CREDENTIALS_ID]) {
                        sh """
                            echo "Copying deployment.yaml to kubectl EC2..."
                            scp -o StrictHostKeyChecking=no deployment.yaml ${SSH_USER}@${KUBECTL_HOST}:/tmp/deployment.yaml

                            ssh -o StrictHostKeyChecking=no ${SSH_USER}@${KUBECTL_HOST} << EOF
                                set -e

                                echo "Updating kubeconfig..."
                                aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${CLUSTER_NAME}

                                echo "Applying deployment..."
                                kubectl apply -f /tmp/deployment.yaml

                                echo "Updating image to ${IMAGE_TAG}..."
                                kubectl set image deployment/webapp webapp=${IMAGE_TAG}

                                echo "Waiting for rollout..."
                                kubectl rollout status deployment/webapp --timeout=5m

                                echo "Verifying deployment..."
                                kubectl get nodes
                                kubectl get pods
                                kubectl get services
                                kubectl get deployment webapp

                                echo "Cleaning up..."
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
                sh "docker rmi ${IMAGE_TAG} || true"
                sh "docker rmi ${IMAGE_NAME}:latest || true"
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
