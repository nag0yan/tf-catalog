variable "service" {
  description = "The name of the service."
  type        = string
}

variable "account_id" {
  description = "The AWS account ID."
  type        = string
  default     = null
}

variable "region" {
  description = "The AWS region."
  type        = string
  default     = null
}
