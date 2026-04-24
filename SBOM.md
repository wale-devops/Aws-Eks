# Software Bill of Materials (SBOM)

**Project:** AWS EKS CI/CD Pipeline  
**Author:** wale-devops  
**Repository:** https://github.com/wale-devops/Aws-Eks  
**Date:** April 2026  
**Format:** Custom SBOM (SPDX-compatible summary)

---

## Infrastructure Components

| Component | Version | Purpose | License |
|---|---|---|---|
| Terraform | >= 1.0 | Infrastructure provisioning | BSL 1.1 |
| AWS Provider (hashicorp/aws) | ~> 5.0 | AWS resource management | MPL 2.0 |
| Kubernetes Provider (hashicorp/kubernetes) | ~> 2.0 | EKS access entry management | MPL 2.0 |

---

## AWS Services

| Service | Configuration | Purpose |
|---|---|---|
| Amazon VPC | 10.0.0.0/16 | Network isolation |
| Amazon EC2 (Jenkins) | t2.medium, Amazon Linux 2023 | CI/CD server |
| Amazon EC2 (kubectl) | t2.medium, Amazon Linux 2023 | Kubernetes management |
| Amazon EKS | v1.30 | Kubernetes cluster |
| Amazon EKS Node Group | t3.medium x2, AL2_x86_64 | Worker nodes |
| AWS NAT Gateway | Single AZ | Private subnet outbound |
| AWS Internet Gateway | - | Public subnet outbound |
| AWS IAM | Multiple roles | Access control |
| AWS SSM Parameter Store | /eks/kubectl-ip | IP discovery |
| AWS ELB (LoadBalancer) | Auto-provisioned by EKS | Public application access |

---

## Application Runtime

| Component | Version | Purpose | License |
|---|---|---|---|
| nginx | trixie (Debian-based) | Web server / reverse proxy | BSD 2-Clause |

---

## Container Images

| Image | Tag | Registry | Base |
|---|---|---|---|
| olawaledevops/my-app | `:<build_number>` + `latest` | Docker Hub | nginx:trixie |
| nginx | trixie | Docker Hub | Debian (trixie) |

---

## CI/CD Tools

| Tool | Version | Purpose | License |
|---|---|---|---|
| Jenkins | Latest LTS | Pipeline orchestration | MIT |
| Docker | Latest | Image build and push | Apache 2.0 |
| kubectl | Latest compatible with EKS 1.30 | Kubernetes CLI | Apache 2.0 |
| AWS CLI | v2 | AWS operations from EC2 | Apache 2.0 |
| Git | 2.50.1 | Source code management | GPL 2.0 |
| OpenSSH (sshagent) | - | Secure remote execution | BSD |

---

## Jenkins Plugins

| Plugin | Purpose |
|---|---|
| Pipeline | Declarative pipeline support |
| SSH Agent | SSH key management for remote execution |
| Git | GitHub integration |
| Docker Pipeline | Docker build and push |
| Credentials Binding | Secrets management |
| Workspace Cleanup | Post-build cleanup |

---

## IAM Policies (AWS Managed)

| Policy | Attached To | Purpose |
|---|---|---|
| AmazonEKSClusterPolicy | EKS cluster role | EKS cluster management |
| AmazonEKSWorkerNodePolicy | Node role | Worker node EKS access |
| AmazonEKS_CNI_Policy | Node role | Pod networking |
| AmazonEC2ContainerRegistryFullAccess | Node role | ECR image pull |
| AmazonEKSClusterAdminPolicy | kubectl EC2 role | Full cluster admin via access entry |

---

## Custom IAM Policies

| Policy | Attached To | Permissions |
|---|---|---|
| kubectl-extra-policy | kubectl EC2 role | eks:DescribeCluster, eks:ListClusters, ssm:GetParameter, ssm:PutParameter |
| jenkins-policy | Jenkins EC2 role | ssm:GetParameter, ssm:GetParameters, ec2:DescribeInstances |

---

## Network Ports

| Port | Protocol | Component | Direction |
|---|---|---|---|
| 22 | TCP | Jenkins EC2, kubectl EC2 | Inbound |
| 80 | TCP | EKS LoadBalancer | Inbound (public) |
| 8080 | TCP | Jenkins EC2 | Inbound |
| All | All | All EC2 | Outbound |

---

## External Dependencies

| Service | Purpose | URL |
|---|---|---|
| Docker Hub | Container image registry | https://hub.docker.com |
| GitHub | Source code and webhook | https://github.com |
| AWS | Cloud infrastructure | https://aws.amazon.com |

---

## Known Vulnerabilities / Notes

- nginx:trixie is based on Debian trixie (testing). Consider pinning to a stable release for production.
- EC2 instances have port 22 open to `0.0.0.0/0`. Restrict to known IPs in production.
- EC2 instances have port 8080 open to `0.0.0.0/0`. Restrict to known IPs in production.
- Docker Hub credentials are stored as Jenkins credentials — rotate regularly.
- No container image scanning is currently performed in the pipeline. Consider adding Trivy or Snyk.
