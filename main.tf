provider "aws" {
  region = var.region
}

###################
# VPC MODULE
###################
module "vpc" {
  source = "./modules/vpc"
}

###################
# EC2 MODULE
###################
module "ec2" {
  source = "./modules/ec2"

  subnet_id = module.vpc.public_subnet # Use first public subnet
  vpc_id    = module.vpc.vpc_id
  key_name  = var.key_name
}

###################
# EKS MODULE
###################
module "eks" {
  source = "./modules/eks"

  # Pass all private subnets (should be at least 2 in different AZs)
  subnet_ids = module.vpc.private_subnets

  # Or explicitly pass them
  # subnet_ids = [
  #   module.vpc.private_subnet_1,
  #   module.vpc.private_subnet_2
  # ]
}
