data "aws_caller_identity" "current" {}

# Bucket S3 para armazenamento do state do Terraform
resource "aws_s3_bucket" "this" {
  bucket        = "${var.remote_backend.bucket_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Name        = "${var.remote_backend.bucket_name}-${data.aws_caller_identity.current.account_id}"
    Environment = var.remote_backend.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Habilita versionamento no Bucket S3
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia Server-Side padrão (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueio total de acesso público ao Bucket S3
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
