# modules/ec2/main.tf

# ─── SECURITY GROUP ────────────────────────────────────────────────────────────

resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# ─── IAM ROLE + PROFILE FOR JENKINS ───────────────────────────────────────────

resource "aws_iam_role" "jenkins" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_policy" {
  name = "jenkins-policy"
  role = aws_iam_role.jenkins.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/eks/*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-ec2-profile"
  role = aws_iam_role.jenkins.name
}

# ─── IAM ROLE + PROFILE FOR KUBECTL ───────────────────────────────────────────

resource "aws_iam_role" "kubectl" {
  name = "kubectl-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "kubectl_eks_policy" {
  role       = aws_iam_role.kubectl.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy" "kubectl_extra" {
  name = "kubectl-extra-policy"
  role = aws_iam_role.kubectl.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameter",
          "ssm:PutParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/eks/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "kubectl" {
  name = "kubectl-ec2-profile"
  role = aws_iam_role.kubectl.name
}

# ─── JENKINS EC2 ───────────────────────────────────────────────────────────────

resource "aws_instance" "jenkins" {
  ami                    = "ami-0ea87431b78a82070"
  instance_type          = "t2.medium"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name

  user_data = file("${path.module}/scripts/setup-jenkins.sh")

  tags = {
    Name = "Jenkins-Server"
  }
}

# ─── KUBECTL EC2 ───────────────────────────────────────────────────────────────

resource "aws_instance" "kubectl" {
  ami                    = "ami-0ea87431b78a82070"
  instance_type          = "t2.medium"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.kubectl.name

  user_data = file("${path.module}/scripts/setup-kubectl.sh")

  tags = {
    Name = "Kubectl-Server"
  }
}

# ─── SSM PARAMETER FOR KUBECTL IP ─────────────────────────────────────────────

resource "aws_ssm_parameter" "kubectl_ip" {
  name  = "/eks/kubectl-ip"
  type  = "String"
  value = aws_instance.kubectl.public_ip

  tags = {
    Name = "kubectl-public-ip"
  }
}
