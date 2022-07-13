variable "repository_name" {
  type        = string
  description = "Name of the repository"
}

resource "aws_ecr_repository" "dev-repo" {
  name = var.repository_name

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.kms_key_for_ecr_encryption.arn
  }
}

resource "aws_kms_key" "kms_key_for_ecr_encryption" {
  description  = "Multi-region KMS key for encryption of ECR images"
  multi_region = "true"
}
output "repository_url" {
  value = aws_ecr_repository.dev-repo.repository_url
}

