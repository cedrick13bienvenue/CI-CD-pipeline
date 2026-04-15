variable "project_name" {
  description = "Project name prefix for all resource tags"
  type        = string
}

variable "role" {
  description = "Role of this instance (e.g. jenkins, app) — used in Name tag and key pair name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the instance"
  type        = string
}

variable "public_key" {
  description = "SSH public key content — key pair is created in AWS from this"
  type        = string
}

variable "disk_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 10
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the EC2 instance (optional)"
  type        = string
  default     = null
}
