
output "bucket_name" {
    value = aws_s3_bucket.main_bucket.bucket
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.tf_locks.name
}

