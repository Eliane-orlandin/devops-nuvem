variable "aws_region" {
  description = "Região AWS padrão para os recursos do Remote Backend"
  type        = string
  default     = "us-east-1"
}

variable "remote_backend" {
  description = "Configuração estruturada do Remote Backend S3 e DynamoDB Locking"
  type = object({
    bucket_name         = string
    dynamodb_table_name = string
    environment         = string
  })
  default = {
    bucket_name         = "dvn-tfstate-remote-backend"
    dynamodb_table_name = "dvn-tfstate-locks"
    environment         = "global"
  }
}
