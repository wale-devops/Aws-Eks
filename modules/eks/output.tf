output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_certificate" {
  description = "Base64 encoded certificate authority data"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
  sensitive   = true
}

output "node_group_name" {
  description = "EKS node group name"
  value       = aws_eks_node_group.nodes.node_group_name
}

output "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_role_arn" {
  description = "Worker node IAM role ARN"
  value       = aws_iam_role.node_role.arn
}
