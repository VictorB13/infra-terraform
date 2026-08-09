variable "project_name" {
  description = "Project name used for tagging all resources"
  type        = string
  default     = "todo-app"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state and backups"
  type        = string
}

variable "public_key_path" {
  description = "Path to local SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}