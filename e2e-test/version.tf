# ============================================================================
# Terraform Version Constraints
# ============================================================================

terraform {

  //required_version = ">= 0.39.3"

  required_providers {
    harness = {
      source = "harness/harness"
      // version = "0.42.7"
      // version = "0.42.0"
      version = "0.100.0-dev"
      # version commented out for dev provider override
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
