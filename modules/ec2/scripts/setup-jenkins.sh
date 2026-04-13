#!/bin/bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker git

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user


# update
sudo yum update –y  # Add the Jenkins repo using the following command
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/rpm-stable/jenkins.repo

# Import a key file from Jenkins-CI to enable installation from the package
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
sudo yum upgrade

# Install Java
sudo yum install java-21-amazon-corretto -y

# Install Jenkins
sudo yum install jenkins -y

# Enable the Jenkins service to start at boot
sudo systemctl enable jenkins
 
# Start Jenkins as a service
sudo systemctl start jenkins
