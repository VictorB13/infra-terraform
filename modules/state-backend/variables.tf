# Input variables - values passed to the module from the root main.tf file
variable "bucket_name" {
    description = "Name of the S3 bucket to store the terraform state file"
    type = string 
}

variable "dynamodb_table_name" {
    description = "Name of the DynamoDB table to store the terraform state lock"
    type = string
}