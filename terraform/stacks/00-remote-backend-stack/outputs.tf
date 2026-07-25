output "s3_bucket_name" {
  description = "Nome do bucket S3 criado para o remote backend"
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3 criado para o remote backend"
  value       = aws_s3_bucket.this.arn
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB criada para o state locking"
  value       = aws_dynamodb_table.this.name
}
