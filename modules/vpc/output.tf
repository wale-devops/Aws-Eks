output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet" {
  value = aws_subnet.public.id
}

output "private_subnet_1" {
  value = aws_subnet.private_1.id
}

output "private_subnet_2" {
  value = aws_subnet.private_2.id
}

output "private_subnets" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "availability_zones" {
  value = [aws_subnet.private_1.availability_zone, aws_subnet.private_2.availability_zone]
}

# Debug: Show AZs for verification
output "subnet_availability_zones" {
  value = {
    private_1_az = aws_subnet.private_1.availability_zone
    private_2_az = aws_subnet.private_2.availability_zone
  }
}
