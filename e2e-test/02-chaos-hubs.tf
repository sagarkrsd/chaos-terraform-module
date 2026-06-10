# ============================================================================
# Step 3: Chaos Hubs at All Scopes (Account, Org, Project)
# ============================================================================

# ----------------------------------------------------------------------------
# Account Level Chaos Hub
# ----------------------------------------------------------------------------
# NOTE: This hub must be destroyed AFTER all templates that reference it
# Templates: action_template, probe_template, fault_template, experiment_template
resource "harness_chaos_hub_v2" "account_level" {
  count = local.create_account_hub ? 1 : 0

  # Account level - no org_id or project_id
  identity    = var.chaos_hub_account_identity
  name        = var.chaos_hub_account_name
  description = "Account-level chaos hub for E2E test"

  tags = var.chaos_hub_tags

  lifecycle {
    ignore_changes = [tags]
    # Prevent accidental deletion since templates depend on this
    # Comment this out when doing terraform destroy
    # prevent_destroy = true
  }
}

# ----------------------------------------------------------------------------
# Org Level Chaos Hub
# ----------------------------------------------------------------------------
# NOTE: This hub must be destroyed AFTER all templates that reference it
resource "harness_chaos_hub_v2" "org_level" {
  count = local.create_org_hub ? 1 : 0

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
    # Prevent accidental deletion since templates depend on this
    # Comment this out when doing terraform destroy
    # prevent_destroy = true
  }
}

# ----------------------------------------------------------------------------
# Project Level Chaos Hub
# ----------------------------------------------------------------------------
# NOTE: This hub must be destroyed AFTER all templates that reference it
resource "harness_chaos_hub_v2" "project_level" {
  count = local.create_project_hub ? 1 : 0

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
    # Prevent accidental deletion since templates depend on this
    # Comment this out when doing terraform destroy
    # prevent_destroy = true
  }
}
