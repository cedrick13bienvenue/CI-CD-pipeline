output "vpc_id" {
  description = "VPC ID — consumed by the security-group module"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public subnet ID — consumed by the ec2 module"
  value       = aws_subnet.public.id
}
