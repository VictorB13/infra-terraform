# Configures where Terraform stores its state file
# S3 bucket must exist BEFORE running terraform init with this file
# Create it first using modules/state-backend separately

terraform {
  backend "s3" {
    bucket         = "todo-app-tfstate-victor"
    key            = "prod/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "todo-app-terraform-locks"
  }
}