# ============================================================================
# Terraform Version Constraints
# ============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    harness = {
      source = "harness/harness"
      # Chaos Infrastructure V2, Service Discovery, Image Registry, Chaos Hub V2,
      # template (action/probe/fault/experiment) and Security Governance V3
      # resources require a recent Harness provider. Use the latest release.
      version = ">= 0.42.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
