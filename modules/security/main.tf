# Security Group - AWS network firewall for the EC2 instance
# Host-level hardening (iptables, not ufw) is applied later by Ansible
resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = "Security group for the EC2 instance"
  vpc_id      = var.vpc_id

  # HTTP — app / ingress
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS — app / cert-manager / Let's Encrypt
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH — Ansible provision + admin access
  # Further restricted on the host with iptables
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # kube-apiserver is NOT exposed publicly
  # Use SSH tunnel or kubectl from the node itself

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
