data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = var.account_id != null ? var.account_id : data.aws_caller_identity.current.account_id
  region     = var.region != null ? var.region : data.aws_region.current.region
}
