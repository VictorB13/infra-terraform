variable "project_name" {
  description = "Project name used for tagging resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 will be placed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the EC2"
  type        = string
}

variable "public_key_path" {
  description = "Path to your local SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "bucket_name" {
  description = "S3 bucket name — used for IAM policy permissions"
  type        = string
}