output "jenkins_public_ip" {
  description = "Public IP of the Jenkins server"
  value       = module.jenkins_ec2.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS of the Jenkins server"
  value       = module.jenkins_ec2.public_dns
}

output "app_public_ip" {
  description = "Public IP of the app deploy target"
  value       = module.app_ec2.public_ip
}

output "app_public_dns" {
  description = "Public DNS of the app deploy target — use this to verify the deployment"
  value       = module.app_ec2.public_dns
}

output "jenkins_url" {
  description = "Jenkins UI URL"
  value       = "http://${module.jenkins_ec2.public_ip}:8080"
}

output "app_url" {
  description = "App URL after deployment"
  value       = "http://${module.app_ec2.public_ip}:3000"
}

output "ansible_command" {
  description = "Run this after terraform apply to configure both servers"
  value       = "cd infra/ansible && ansible-playbook -i inventory.ini site.yml"
}
