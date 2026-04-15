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
