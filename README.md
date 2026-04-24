# AWS EKS CI/CD Pipeline

A fully automated CI/CD pipeline that builds, pushes, and deploys a containerised web application to AWS EKS using Jenkins, Docker, Terraform, and kubectl.

---

## Architecture Overview

```
GitHub → Jenkins EC2 → Docker Hub → Kubectl EC2 → EKS Cluster → LoadBalancer → Internet
```

The infrastructure is provisioned entirely with Terraform using a modular structure. Jenkins listens for GitHub webhook pushes, builds a Docker image, pushes it to Docker Hub, then SSHs into a dedicated kubectl EC2 instance to apply the Kubernetes deployment to the EKS cluster.

---

## Project Structure

```
Aws-Eks/
├── main.tf                        # Root Terraform config
├── variable.tf                    # Root variables
├── output.tf                      # Root outputs
├── Jenkinsfile                    # CI/CD pipeline definition
├── deployment.yaml                # Kubernetes Deployment + Service
├── modules/
│   ├── vpc/
│   │   ├── main.tf                # VPC, subnets, IGW, NAT, route tables
│   │   ├── variables.tf
│   │   └── output.tf
│   ├── ec2/
│   │   ├── main.tf                # Jenkins + kubectl EC2, IAM roles, SSM
│   │   ├── variables.tf
│   │   ├── output.tf
│   │   └── scripts/
│   │       ├── setup-jenkins.sh
│   │       └── setup-kubectl.sh
│   └── eks/
│       ├── main.tf                # EKS cluster, node group, IAM, access entries
│       ├── variables.tf
│       └── output.tf
└── Webapp/
    ├── Dockerfile
    └── Src/
        ├── index.html
        └── dog.jpg
```

---

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- An EC2 key pair in us-east-1
- Docker Hub account
- GitHub repository with webhook configured to Jenkins

---

## Infrastructure

### VPC module

- VPC CIDR: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24` (AZ 1)
- Private subnet 1: `10.0.2.0/24` (AZ 1)
- Private subnet 2: `10.0.3.0/24` (AZ 2)
- Internet Gateway for public subnet outbound
- NAT Gateway for private subnet outbound
- Route tables for both public and private subnets

### EC2 module

- Jenkins server (`t2.medium`) in the public subnet with port 8080 open
- Kubectl server (`t2.medium`) in the public subnet with port 22 open
- IAM role for Jenkins with SSM read access to fetch kubectl IP
- IAM role for kubectl with EKS cluster access
- SSM Parameter Store entry `/eks/kubectl-ip` storing the kubectl EC2 public IP

### EKS module

- EKS cluster version 1.30 in private subnets
- Managed node group with 2x `t3.medium` nodes (min 1, max 3)
- Authentication mode set to `API_AND_CONFIG_MAP`
- IAM access entry for the kubectl EC2 role with `AmazonEKSClusterAdminPolicy`
- Worker node IAM role with EKS, CNI, and ECR policies

---

## Deployment

### 1. Clone the repository

```bash
git clone https://github.com/wale-devops/Aws-Eks.git
cd Aws-Eks
```

### 2. Initialise and apply Terraform

```bash
terraform init
terraform apply -var="key_name=your-key-pair-name"
```

### 3. Configure Jenkins

After apply completes, get the Jenkins IP:

```bash
terraform output jenkins_ip
```

Open `http://<jenkins-ip>:8080` and configure:

- Install suggested plugins
- Add Docker Hub credentials (ID: `dockerhub-credentials-id`)
- Add EC2 SSH key credentials (ID: `ec2-ssh-key`)
- Create a Pipeline job pointing to your GitHub repo

### 4. Trigger the pipeline

Push to the `master` branch or trigger manually in Jenkins. The pipeline will:

1. Check out code from GitHub
2. Build the Docker image from `./Webapp`
3. Push the image to Docker Hub with the build number tag
4. Fetch the kubectl EC2 IP from SSM Parameter Store
5. SCP the deployment file to the kubectl EC2
6. SSH in and run `kubectl apply`
7. Wait for the rollout to complete

### 5. Access the application

```bash
kubectl get services
```

Copy the `EXTERNAL-IP` from `webapp-service` and open it in your browser on port 80.

---

## Environment Variables (Jenkinsfile)

| Variable | Description |
|---|---|
| `IMAGE_NAME` | Docker Hub image name |
| `SSH_USER` | EC2 login user (ec2-user) |
| `SSH_CREDENTIALS_ID` | Jenkins credential ID for SSH key |
| `AWS_DEFAULT_REGION` | AWS region |
| `CLUSTER_NAME` | EKS cluster name |

---

## Teardown

```bash
terraform destroy
```

This will remove all AWS resources including the EKS cluster, EC2 instances, VPC, and IAM roles.

---

## Author

wale-devops
