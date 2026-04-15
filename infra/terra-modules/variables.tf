variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used to prefix all resource names"
  type        = string
  default     = "cicd-jenkins"
}

variable "my_ip" {
  description = "Your public IP in CIDR notation (e.g. 1.2.3.4/32) — restricts Jenkins UI and SSH access"
  type        = string
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins — t3.small minimum (Jenkins needs ~1GB RAM)"
  type        = string
  default     = "t3.small"
}

variable "app_instance_type" {
  description = "EC2 instance type for the app deploy target — must be t3.micro/small/medium per account SCP"
  type        = string
  default     = "t3.micro"
}
