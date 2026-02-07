# ============================================================================
# Step 13: Experiments from Org-Level Templates
# ============================================================================

# ----------------------------------------------------------------------------
# Experiment from Org Complex Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment" "from_org_reference" {
  depends_on = [
    harness_chaos_experiment_template.org_complex,
    harness_chaos_infrastructure_v2.this
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = harness_chaos_experiment_template.org_complex.identity
  hub_identity      = harness_chaos_hub_v2.org_level.identity
  hub_org_id        = harness_chaos_hub_v2.org_level.org_id
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
  depends_on = [
    harness_chaos_experiment_template.org_complex,
    harness_chaos_infrastructure_v2.this
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = harness_chaos_experiment_template.org_complex.identity
  hub_identity      = harness_chaos_hub_v2.org_level.identity
  hub_org_id        = harness_chaos_hub_v2.org_level.org_id
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
