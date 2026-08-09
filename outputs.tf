# EC2 public IP — used by Ansible to connect to the server
# also printed after terraform apply so you know where your server is
output "ec2_public_ip" {
  value       = module.compute.public_ip
  description = "Public IP of the EC2 instance"
}

output "ec2_public_dns" {
  value       = module.compute.public_dns
  description = "Public DNS of the EC2 instance"
}