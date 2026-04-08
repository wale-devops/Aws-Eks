output "jenkins_ip" {
  value = module.ec2.jenkins_public_ip
}

output "kubectl_ip" {
  value = module.ec2.kubectl_public_ip
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
