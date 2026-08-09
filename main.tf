# Root main.tf — calls all modules and passes values between them

# Network module — creates VPC, subnet, IGW, route table
module "network" {
  source            = "./modules/network"
  project_name      = var.project_name
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
}

# Security module — creates security groups
# vpc_id comes from network module output
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.network.vpc_id
}

# Compute module — creates EC2, key pair, IAM role
# subnet_id and security_group_id come from previous modules
module "compute" {
  source            = "./modules/compute"
  project_name      = var.project_name
  subnet_id         = module.network.subnet_id
  security_group_id = module.security.security_group_id
  bucket_name       = var.bucket_name
  public_key_path   = var.public_key_path
}