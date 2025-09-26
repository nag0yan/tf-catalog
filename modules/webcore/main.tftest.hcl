provider "aws" {
  region = "ap-northeast-1"
}

run "webcore" {
  command = plan

  variables {
    service         = "test-service"
    vpc_id          = "vpc-EXAMPLE"
    private_subnets = ["subnet-EXAMPLE", "subnet-EXAMPLE2"]
  }

  assert {
    condition     = length(aws_lb.main.*.id) == 1
    error_message = "Expected exactly one ALB to be created."
  }
}
