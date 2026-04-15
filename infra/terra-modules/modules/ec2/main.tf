# Key pair — created from the public key passed in from the root module
resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-${var.role}-key"
  public_key = var.public_key
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.this.key_name
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-${var.role}"
    Project = var.project_name
    Role    = var.role
  }
}
