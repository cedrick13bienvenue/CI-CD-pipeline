variable "aws_region" {
  description = "AWS region — used to pin the subnet to the first AZ"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for all resource tags"
  type        = string
}
