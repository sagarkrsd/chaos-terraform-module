# ============================================================================
# Step 1-2: Foundation - Organization and Project
# ============================================================================

locals {
  # Common tags for all resources
  common_tags = {
    "module"      = "chaos-e2e-test"
    "managed_by"  = "terraform"
    "environment" = "test"
  }

  # Convert tags map to set of strings for resources that require it
  tags_set = [for k, v in local.common_tags : "${k}=${v}"]
  
  # Infrastructure reference for experiments (format: env_id/infra_id)
  infra_ref = "${harness_platform_environment.this.id}/${harness_platform_infrastructure.this.id}"
}

# ----------------------------------------------------------------------------
# Step 1: Create Organization
# ----------------------------------------------------------------------------
resource "harness_platform_organization" "this" {
  identifier  = var.org_identifier
  name        = var.org_name
  description = "Organization for Chaos Engineering E2E Test"
  tags        = local.tags_set
}

# ----------------------------------------------------------------------------
# Step 2: Create Project
# ----------------------------------------------------------------------------
resource "harness_platform_project" "this" {
  depends_on = [
    harness_platform_organization.this
  ]

  org_id      = harness_platform_organization.this.id
  identifier  = var.project_identifier
  name        = var.project_name
  color       = var.project_color
  description = "Project for Chaos Engineering E2E Test"
  tags        = local.tags_set
}

# ----------------------------------------------------------------------------
# Kubernetes Connector (Required for Infrastructure)
# ----------------------------------------------------------------------------
resource "harness_platform_connector_kubernetes" "this" {
  depends_on = [
    harness_platform_project.this
  ]

  identifier = var.k8s_connector_identifier
  name       = var.k8s_connector_name
  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id

  inherit_from_delegate {
    delegate_selectors = var.delegate_selectors
  }

  tags = local.tags_set
}
