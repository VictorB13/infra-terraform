# S3 bucket- stores the terraform state file and backups
# State file - JSON file that contains the current state of the infrastructure managed by Terraform
resource "aws_s3_bucket" "main_bucket" {
    bucket = var.bucket_name # Name of the S3 bucket

    # Prevent the bucket from being destroyed
    lifecycle {
        prevent_destroy = true
    }
}

# Versioning - keeps history of state file change, can rollback to previous state if needed
resource "aws_s3_bucket_versioning" "main_bucket" {
    bucket = aws_s3_bucket.main_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

# Encryption - encrypts the state files with AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "main_bucket" {
    bucket = aws_s3_bucket.main_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# Block public access - prevents access to state files
resource "aws_s3_bucket_public_access_block" "main_bucket" {
    bucket = aws_s3_bucket.main_bucket.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# DynamoDB table - used for state locking
# When someone runs terrafom apply, it creats a lock
# If another user tries to run terraform apply at the same time, it will fail
# LockID - primary key for the table, used to identify the lock
resource "aws_dynamodb_table" "tf_locks" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST" # Pay per request mode, not upfront cost
    hash_key = "LockID" # Primary key for the table

    attribute {
        name = "LockID"
        type = "S" # S - String
    }
}