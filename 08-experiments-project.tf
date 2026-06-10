# ============================================================================
# Step 11: Experiments from Project-Level Templates
# ============================================================================

# ----------------------------------------------------------------------------
# Experiment from Project Complex Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment" "from_project_reference" {
  count = local.create_experiments && var.enable_project_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_experiment_template.project_complex,
    harness_chaos_infrastructure_v2.this,
    # Real-world ordering: the infra must be fully ready (service discovery
    # running + image registry configured) before experiments run.
    harness_service_discovery_agent.this,
    harness_chaos_image_registry.test_project_level,
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = local.exp_template_project_complex_identity
  hub_identity      = local.project_hub_identity
  hub_org_id        = harness_platform_organization.this.id
  hub_project_id    = harness_platform_project.this.id
  name              = "E2E-Exp-From-Project-Reference"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"

  identity    = "e2e-exp-from-project-reference"
  description = "Experiment created from project-level complex template with 2 faults and 4 probes"
  tags        = ["e2e", "project", "reference", "complex", "experiment"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# Experiment from Project Complex Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment" "from_project_local" {
  count = local.create_experiments && var.enable_project_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_experiment_template.project_complex,
    harness_chaos_infrastructure_v2.this,
    # Real-world ordering: the infra must be fully ready (service discovery
    # running + image registry configured) before experiments run.
    harness_service_discovery_agent.this,
    harness_chaos_image_registry.test_project_level,
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = local.exp_template_project_complex_identity
  hub_identity      = local.project_hub_identity
  hub_org_id        = harness_platform_organization.this.id
  hub_project_id    = harness_platform_project.this.id
  name              = "E2E-Exp-From-Project-Local"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"

  identity    = "e2e-exp-from-project-local"
  description = "Experiment created from project-level complex template with 2 faults and 4 probes"
  tags        = ["e2e", "project", "local", "complex", "experiment"]

  lifecycle {
    ignore_changes = [tags]
  }
}
