# Public IP — needed for:
# 1. Ansible to connect and configure the server
# 2. Route53 DNS record (when we add it later)
output "public_ip" {
  value = aws_instance.main.public_ip
}

# Public DNS — the AWS-assigned hostname for the EC2
output "public_dns" {
  value = aws_instance.main.public_dns
}