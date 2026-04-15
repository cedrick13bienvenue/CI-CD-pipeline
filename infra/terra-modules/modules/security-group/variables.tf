variable "vpc_id" {
  description = "VPC ID to attach security groups to"
  type        = string
}

variable "my_ip" {
  description = "Your public IP in CIDR notation (e.g. 1.2.3.4/32) — restricts SSH and Jenkins UI access"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for all resource tags"
  type        = string
}
