resource "aws_s3_bucket" "default" {
  bucket = var.name
  tags   = var.tags
}
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.default.id
  acl    = var.acl
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = lookup(var.public_access_blocking, "block_public_acls", true)
  block_public_policy     = lookup(var.public_access_blocking, "block_public_policy", true)
  ignore_public_acls      = lookup(var.public_access_blocking, "ignore_public_acls", true)
  restrict_public_buckets = lookup(var.public_access_blocking, "restrict_public_buckets", true)
}
