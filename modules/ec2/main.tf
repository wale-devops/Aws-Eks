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
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0ea87431b78a82070"
  instance_type          = "t2.small"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = file("${path.module}/scripts/setup-jenkins.sh")

  tags = {
    Name = "Jenkins-Server"
  }
}

resource "aws_instance" "kubectl" {
  ami                    = "ami-0ea87431b78a82070"
  instance_type          = "t2.small"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = file("${path.module}/scripts/setup-kubectl.sh")

  tags = {
    Name = "Kubectl-Server"
  }
}
