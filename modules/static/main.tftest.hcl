provider "aws" {
  region = "ap-northeast-1"
}

run "standard_use" {
  command = plan

  variables {
    service    = "test-service"
    account_id = "123456789012"
    region     = "ap-northeast-1"
  }

  # S3 Bucket
  assert {
    condition     = aws_s3_bucket.main.bucket == "test-service-123456789012-ap-northeast-1"
    error_message = "The bucket name is incorrect."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.main.bucket == aws_s3_bucket.main.bucket
    error_message = "The public access block is not associated with the correct bucket."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.main.block_public_acls == true
    error_message = "The public access block should block public ACLs."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.main.block_public_policy == true
    error_message = "The public access block should block public policies."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.main.ignore_public_acls == true
    error_message = "The public access block should ignore public ACLs."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.main.restrict_public_buckets == true
    error_message = "The public access block should restrict public buckets."
  }

  # Bucket Policy
  assert {
    condition     = data.aws_iam_policy_document.main.statement[0].sid == "AllowReadAccessFromCloudFront"
    error_message = "The bucket policy should allow read access from CloudFront."
  }
  assert {
    condition     = contains(data.aws_iam_policy_document.main.statement[0].actions, "s3:GetObject")
    error_message = "The bucket policy should allow s3:GetObject action."
  }
  assert {
    condition     = contains(data.aws_iam_policy_document.main.statement[0].actions, "s3:ListBucket")
    error_message = "The bucket policy should allow s3:ListBucket action."
  }

  # CloudFront Distribution
  assert {
    condition     = aws_cloudfront_distribution.main.enabled == true
    error_message = "The CloudFront distribution should be enabled."
  }
  assert {
    condition     = aws_cloudfront_distribution.main.default_cache_behavior[0].cache_policy_id == "658327ea-f89d-4fab-a63d-7e88639e58f6"
    error_message = "The CloudFront distribution should use the Managed-CachingOptimized cache policy."
  }
  assert {
    condition     = aws_cloudfront_distribution.main.default_cache_behavior[0].viewer_protocol_policy == "redirect-to-https"
    error_message = "The CloudFront distribution should redirect HTTP to HTTPS."
  }
}

run "non_optional_inputs" {
  command = plan
  variables {
    service = "test-service"
  }

  # S3 Bucket
  assert {
    condition     = can(regex("^test-service-[0-9]{12}-ap-northeast-1$", aws_s3_bucket.main.bucket))
    error_message = "The bucket name is incorrect."
  }
}
