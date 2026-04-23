#!/bin/bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y  docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install kubectl
apt install -y curl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.3/2026-04-08/bin/linux/arm64/kubectl && \
chmod +x kubectl && \
sudo mv kubectl /usr/local/bin/

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure kubeconfig for EKS
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
