# ============================================================================
# Step 3: Chaos Hubs at All Scopes (Account, Org, Project)
# ============================================================================

# ----------------------------------------------------------------------------
# Account Level Chaos Hub
# ----------------------------------------------------------------------------
resource "harness_chaos_hub_v2" "account_level" {
  # Account level - no org_id or project_id
  identity    = var.chaos_hub_account_identity
  name        = var.chaos_hub_account_name
  description = "Account-level chaos hub for E2E test"

  tags = var.chaos_hub_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# Org Level Chaos Hub
# ----------------------------------------------------------------------------
resource "harness_chaos_hub_v2" "org_level" {
  depends_on = [
    harness_platform_organization.this
  ]

  # Org level - org_id only
  org_id      = harness_platform_organization.this.id
  identity    = var.chaos_hub_org_identity
  name        = var.chaos_hub_org_name
  description = "Org-level chaos hub for E2E test"

  tags = var.chaos_hub_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# Project Level Chaos Hub
# ----------------------------------------------------------------------------
resource "harness_chaos_hub_v2" "project_level" {
  depends_on = [
    harness_platform_project.this
  ]

  # Project level - org_id and project_id
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  identity    = var.chaos_hub_project_identity
  name        = var.chaos_hub_project_name
  description = "Project-level chaos hub for E2E test"

  tags = var.chaos_hub_tags

  lifecycle {
    ignore_changes = [tags]
  }
}
