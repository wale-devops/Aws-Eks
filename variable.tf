variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "EC2 Key Pair"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (must be in at least 2 different AZs for EKS)"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
