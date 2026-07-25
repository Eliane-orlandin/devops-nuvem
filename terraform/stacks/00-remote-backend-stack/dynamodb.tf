# Tabela DynamoDB para controle de trava de estado (State Locking)
resource "aws_dynamodb_table" "this" {
  name         = var.remote_backend.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.remote_backend.dynamodb_table_name
    Environment = var.remote_backend.environment
    ManagedBy   = "Terraform"
  }
}
