# variables.tf

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EKS cluster (must be in at least 2 different AZs)"
}
