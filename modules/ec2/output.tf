output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "kubectl_public_ip" {
  description = "Public IP of kubectl server"
  value       = aws_instance.kubectl.public_ip
}

output "jenkins_private_ip" {
  description = "Private IP of Jenkins server"
  value       = aws_instance.jenkins.private_ip
}

output "kubectl_private_ip" {
  description = "Private IP of kubectl server"
  value       = aws_instance.kubectl.private_ip
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = aws_security_group.ec2_sg.id
}
