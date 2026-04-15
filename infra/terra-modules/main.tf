terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  # Remote backend — state stored in S3, locked via DynamoDB (created in Stage 1)
  backend "s3" {
    bucket         = "cicd-jenkins-tf-state"
    key            = "cicd-jenkins/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "cicd-jenkins-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Latest Amazon Linux 2 AMI — auto-resolves the correct ID for the region
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Modules ────────────────────────────────────────────────────────────────────

module "vpc" {
  source       = "./modules/vpc"
  aws_region   = var.aws_region
  project_name = var.project_name
}

module "security_group" {
  source       = "./modules/security-group"
  vpc_id       = module.vpc.vpc_id
  my_ip        = var.my_ip
  project_name = var.project_name
}

# Jenkins EC2 — t3.small + 20GB disk (Jenkins workspace needs headroom)
module "jenkins_ec2" {
  source            = "./modules/ec2"
  project_name      = var.project_name
  role              = "jenkins"
  ami_id            = data.aws_ami.amazon_linux_2.id
  instance_type     = var.jenkins_instance_type
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.security_group.jenkins_sg_id
  public_key        = file("../../keys/cicd-jenkins-key.pub")
  disk_size         = 20
}

# App EC2 — t2.micro, just runs one Docker container
module "app_ec2" {
  source            = "./modules/ec2"
  project_name      = var.project_name
  role              = "app"
  ami_id            = data.aws_ami.amazon_linux_2.id
  instance_type     = var.app_instance_type
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.security_group.app_sg_id
  public_key        = file("../../keys/cicd-jenkins-key.pub")
  disk_size         = 10
}

# Auto-generate inventory.ini — Ansible reads this to know which hosts to configure
resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [jenkins]
    ${module.jenkins_ec2.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=../../keys/cicd-jenkins-key ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3

    [app]
    ${module.app_ec2.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=../../keys/cicd-jenkins-key ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3
  EOT
}
