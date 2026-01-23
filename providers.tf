variable "harness_endpoint" {
  type        = string
  description = "Harness endpoint"
  default     = "https://app.harness.io/gateway"
}

variable "harness_account_id" {
  type        = string
  description = "Harness account ID"
}

variable "harness_platform_api_key" {
  type        = string
  description = "Harness platform API key"
  sensitive   = true
}

provider "harness" {
  endpoint         = var.harness_endpoint
  account_id       = var.harness_account_id
  platform_api_key = var.harness_platform_api_key
}
