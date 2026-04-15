terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket — stores Terraform remote state for the main infra stage
resource "aws_s3_bucket" "tf_state" {
  bucket        = "${var.project_name}-tf-state"
  force_destroy = true

  tags = {
    Name    = "${var.project_name}-tf-state"
    Project = var.project_name
  }
}

# Versioning — allows rollback to a previous state file if something goes wrong
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access — state files contain sensitive infrastructure details
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table — state locking prevents two engineers applying at the same time
resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.project_name}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "${var.project_name}-tf-lock"
    Project = var.project_name
  }
}
