resource "aws_s3_bucket" "main" {
  bucket = "${var.service}-${local.account_id}-${local.region}"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
