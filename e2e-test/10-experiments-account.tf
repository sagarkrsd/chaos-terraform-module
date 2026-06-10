# ============================================================================
# Step 12 & 14: Experiments from Account-Level Templates
# ============================================================================

# ----------------------------------------------------------------------------
# Experiment from Account Complex Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment" "from_account_reference" {
  count = local.create_experiments && var.enable_account_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_experiment_template.account_complex,
    harness_chaos_infrastructure_v2.this
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = local.exp_template_account_complex_identity
  hub_identity      = "${local.account_hub_identity}"
  name              = "E2E-Exp-From-Account-Reference"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"

  identity    = "e2e-exp-from-account-reference"
  description = "Experiment created from account-level complex template with 2 faults and 4 probes"
  tags        = ["e2e", "account", "reference", "complex", "experiment"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# Experiment from Account Complex Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment" "from_account_local" {
  count = local.create_experiments && var.enable_account_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_experiment_template.account_complex,
    harness_chaos_infrastructure_v2.this
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = local.exp_template_account_complex_identity
  hub_identity      = "${local.account_hub_identity}"
  name              = "E2E-Exp-From-Account-Local"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"

  identity    = "e2e-exp-from-account-local"
  description = "Experiment created from account-level complex template with 2 faults and 4 probes"
  tags        = ["e2e", "account", "local", "complex", "experiment"]

  lifecycle {
    ignore_changes = [tags]
  }
}
