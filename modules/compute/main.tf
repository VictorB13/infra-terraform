# AMI data source to fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" { 
    most_recent = true
    owners = ["099720109477"] # Canonical's AWS account ID for Ubuntu AMIs

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

# Keypair - ssh public key to be used for the instance
resource "aws_key_pair" "main" {
    key_name   = "${var.project_name}-key"
    public_key = file(var.public_key_path)
}

# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
    name = "${var.project_name}-ec2-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

# Instance Profile — the bridge between IAM Role and EC2
# You can't attach an IAM Role directly to an EC2
# you attach it via an Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Instance — the actual server
# t2.micro is free tier eligible (1 vCPU, 1GB RAM)
resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Root volume — 20GB is enough for K3s + Docker images
  # gp3 is faster and cheaper than gp2
  # encrypted = true encrypts data at rest on the disk
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-server"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}



