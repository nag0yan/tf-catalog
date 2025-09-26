variable "service" {
  description = "The name of the service."
  type        = string
}

variable "account_id" {
  description = "The AWS account ID.(Optional)"
  type        = string
  default     = null
}

variable "region" {
  description = "The AWS region.(Optional)"
  type        = string
  default     = null
  validation {
    condition     = var.region == null || contains(local.allowed_region, var.region)
    error_message = "The specified region is not supported. Supported regions are: ${join(", ", local.allowed_region)}"
  }
}

variable "vpc_id" {
  description = "The VPC ID to launch resources in."
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs to launch resources in."
  type        = list(string)
}
