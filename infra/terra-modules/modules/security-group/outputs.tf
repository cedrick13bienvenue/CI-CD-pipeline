output "jenkins_sg_id" {
  description = "Jenkins security group ID — passed to the Jenkins EC2 module"
  value       = aws_security_group.jenkins.id
}

output "app_sg_id" {
  description = "App security group ID — passed to the App EC2 module"
  value       = aws_security_group.app.id
}
