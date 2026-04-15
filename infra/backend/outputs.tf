output "s3_bucket_name" {
  description = "S3 bucket name for remote state — use this in the main stage backend block"
  value       = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking — use this in the main stage backend block"
  value       = aws_dynamodb_table.tf_lock.name
}
