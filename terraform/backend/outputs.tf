output "bucket_name" {  
    value = aws_s3_bucket.terraform-state.bucket
}

output "table_name" {
    value = aws_dynamodb_table.terraform-state.name
}