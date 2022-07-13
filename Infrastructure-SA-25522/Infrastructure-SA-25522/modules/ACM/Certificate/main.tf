resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = "dev"
    Repository = "https://github.com/VacaAPI/Infrastructure/tree/master/modules/ACM/Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "arn" {
  value = aws_acm_certificate.certificate.arn
}
