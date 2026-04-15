# ── Jenkins Security Group ─────────────────────────────────────────────────────
# SSH and port 8080 restricted to your IP only — Jenkins UI must never be public
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Jenkins server: SSH and UI access from operator IP only"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project_name}-jenkins-sg"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh" {
  security_group_id = aws_security_group.jenkins.id
  description       = "SSH from operator IP only"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_ui" {
  security_group_id = aws_security_group.jenkins.id
  description       = "Jenkins UI from operator IP only"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_egress_rule" "jenkins_outbound" {
  security_group_id = aws_security_group.jenkins.id
  description       = "All outbound - Jenkins pulls from GitHub, Docker Hub, apt repos"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ── App Security Group ─────────────────────────────────────────────────────────
# SSH allowed from Jenkins SG only — only Jenkins deploys to this server
# App port 3000 open to the world — verifier needs to access the deployed app
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "App server: SSH from Jenkins only, app port open publicly"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project_name}-app-sg"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh_jenkins" {
  security_group_id            = aws_security_group.app.id
  description                  = "SSH from Jenkins server for deployments"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.jenkins.id
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh_operator" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from operator IP for Ansible configuration"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_ingress_rule" "app_port" {
  security_group_id = aws_security_group.app.id
  description       = "App port open publicly for lab verification"
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_outbound" {
  security_group_id = aws_security_group.app.id
  description       = "All outbound - app server pulls Docker images"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
