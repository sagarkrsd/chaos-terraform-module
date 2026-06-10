# ============================================================================
# Step 13: Experiments from Org-Level Templates
# ============================================================================

# ----------------------------------------------------------------------------
# Experiment from Org Complex Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment" "from_org_reference" {
  count = local.create_experiments && var.enable_org_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_experiment_template.org_complex,
    harness_chaos_infrastructure_v2.this
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = local.exp_template_org_complex_identity
  hub_identity      = "${local.org_hub_identity}"
  hub_org_id        = harness_platform_organization.this.id
  name              = "E2E-Exp-From-Org-Reference"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"

  identity    = "e2e-exp-from-org-reference"
  description = "Experiment created from org-level complex template with 2 faults and 4 probes"
  tags        = ["e2e", "org", "reference", "complex", "experiment"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# Experiment from Org Complex Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment" "from_org_local" {
  count = local.create_experiments && var.enable_org_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_experiment_template.org_complex,
    harness_chaos_infrastructure_v2.this
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = local.exp_template_org_complex_identity
  hub_identity      = "${local.org_hub_identity}"
  hub_org_id        = harness_platform_organization.this.id
  name              = "E2E-Exp-From-Org-Local"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"

  identity    = "e2e-exp-from-org-local"
  description = "Experiment created from org-level complex template with 2 faults and 4 probes"
  tags        = ["e2e", "org", "local", "complex", "experiment"]

  lifecycle {
    ignore_changes = [tags]
  }
}
