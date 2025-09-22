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

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AllowReadAccessFromCloudFront"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["${aws_s3_bucket.main.arn}", "${aws_s3_bucket.main.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${aws_s3_bucket.main.bucket}-oac"
  description                       = "Origin Access Control for ${aws_s3_bucket.main.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  origin_id = "S3-${aws_s3_bucket.main.bucket}"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    domain_name              = aws_s3_bucket.main.bucket_domain_name
  }
  enabled = true
  comment = "Static resource distribution for ${var.service}"
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}
