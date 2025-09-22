provider "aws" {
  region = "ap-northeast-1"
}

run "check_bucket_name" {
  command = plan

  variables {
    service = "test-service"
    account_id = "123456789012"
    region = "ap-northeast-1"
  }

  assert {
    condition = aws_s3_bucket.main.bucket == "test-service-123456789012-ap-northeast-1"
    error_message = "The bucket name is incorrect."
  }
}
