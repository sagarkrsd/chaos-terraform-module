# Experiment Tests - Enterprise Hub Templates
# This file tests creating experiments from experiment templates that use ENTERPRISE templates
# (fault templates, probe templates, and action templates from the enterprise hub)

# Enable this test by setting the variable
variable "enable_experiment_enterprise_templates_test" {
  description = "Enable experiment tests with enterprise hub templates"
  type        = bool
  default     = false
}

# ============================================================================
# Test 1: Experiment from Simple Enterprise Fault Template
# ============================================================================

resource "harness_chaos_experiment" "from_enterprise_fault" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id            = harness_platform_organization.this[0].id
  project_id        = harness_platform_project.this[0].id
  template_identity = harness_chaos_experiment_template.simple_fault_only[0].identity
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Fault-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref  # Format: env_id/infra_id (computed from environment and infrastructure)
  import_type       = "REFERENCE"  # Template reference

  
  description = "Experiment created from enterprise fault template"
  tags        = ["test", "terraform", "enterprise-fault", "experiment"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

# ============================================================================
# Test 2: Experiment from Enterprise Fault + Probe (Parallel)
# ============================================================================

resource "harness_chaos_experiment" "from_enterprise_fault_probe_parallel" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.fault_with_probe_parallel) > 0 ? harness_chaos_experiment_template.fault_with_probe_parallel[0].identity : null
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Fault-Probe-Parallel-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"  # Template reference

  
  description = "Experiment with enterprise fault and probe running in parallel"
  tags        = ["test", "terraform", "enterprise-parallel", "experiment"]

  depends_on = [harness_chaos_experiment_template.fault_with_probe_parallel]
}

# ============================================================================
# Test 3: Experiment from Enterprise Fault + Two Probes
# ============================================================================

resource "harness_chaos_experiment" "from_enterprise_two_probes" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.fault_with_two_probes) > 0 ? harness_chaos_experiment_template.fault_with_two_probes[0].identity : null
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Two-Probes-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"
  
  description = "Experiment with enterprise fault and two probes"
  tags        = ["test", "terraform", "enterprise-two-probes", "experiment"]

  depends_on = [harness_chaos_experiment_template.fault_with_two_probes]
}

# ============================================================================
# Test 4: Experiment from Enterprise Template with Action
# ============================================================================

resource "harness_chaos_experiment" "from_enterprise_with_action" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.with_action) > 0 ? harness_chaos_experiment_template.with_action[0].identity : null
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Action-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"
  
  description = "Experiment from enterprise template with action"
  tags        = ["test", "terraform", "enterprise-action", "experiment"]

  depends_on = [harness_chaos_experiment_template.with_action]
}

# ============================================================================
# Test 5: Experiment from Multi-Fault Enterprise Template
# ============================================================================

resource "harness_chaos_experiment" "from_enterprise_multi_fault" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.multi_fault) > 0 ? harness_chaos_experiment_template.multi_fault[0].identity : null
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Multi-Fault-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"
  
  description = "Experiment with multiple enterprise faults"
  tags        = ["test", "terraform", "enterprise-multi-fault", "experiment"]

  depends_on = [harness_chaos_experiment_template.multi_fault]
}

// # ============================================================================
// # Test 6: Experiment from Most Complex Enterprise Template
// # ============================================================================

// resource "harness_chaos_experiment" "from_enterprise_most_complex" {
//   count = var.enable_experiment_enterprise_templates_test ? 1 : 0

//   org_id            = harness_platform_organization.this[0].id
//   project_id        = harness_platform_project.this[0].id
//   template_identity = length(harness_chaos_experiment_template.most_complex) > 0 ? harness_chaos_experiment_template.most_complex[0].identity : null
//   hub_identity      = harness_chaos_hub_v2.project_level[0].identity
//   name              = "Experiment-Enterprise-Most-Complex-${var.experiment_name_suffix}"
//   infra_ref         = local.infra_ref
//   import_type       = "REFERENCE"
  
//   description = "Experiment from most complex enterprise template"
//   tags        = ["test", "terraform", "enterprise-complex", "experiment"]

//   depends_on = [harness_chaos_experiment_template.most_complex]
// }

# ============================================================================
# Test 7: Experiment Referencing Account-Level Template (COMMENTED OUT)
# ============================================================================
# REASON: Template 'account_level' doesn't exist
# TODO: Create account_level template or remove this test

// resource "harness_chaos_experiment" "enterprise_account_level" {
//   count = var.enable_experiment_enterprise_templates_test ? 1 : 0

//   org_id       = harness_platform_organization.this[0].id
//   project_id   = harness_platform_project.this[0].id
//   template_identity = length(harness_chaos_experiment_template.account_level) > 0 ? harness_chaos_experiment_template.account_level[0].identity : null
//   hub_identity      = harness_chaos_hub_v2.account_level[0].identity
//   name              = "Experiment-Enterprise-Account-${var.experiment_name_suffix}"
//   infra_ref         = local.infra_ref
//   import_type       = "LOCAL"
  
//   description = "Account-level experiment from enterprise template"
//   tags        = ["test", "terraform", "enterprise-account", "experiment"]

//   depends_on = [harness_chaos_experiment_template.account_level]
// }

# ============================================================================
# Test 8: Experiment Referencing Org-Level Template (COMMENTED OUT)
# ============================================================================
# REASON: Template 'org_level' doesn't exist
# TODO: Create org_level template or remove this test

// resource "harness_chaos_experiment" "enterprise_org_level" {
//   count = var.enable_experiment_enterprise_templates_test ? 1 : 0

//   org_id            = harness_platform_organization.this[0].id
//   project_id        = harness_platform_project.this[0].id
//   template_identity = length(harness_chaos_experiment_template.org_level) > 0 ? harness_chaos_experiment_template.org_level[0].identity : null
//   hub_identity      = harness_chaos_hub_v2.project_level[0].identity
//   name              = "Experiment-Enterprise-Org-${var.experiment_name_suffix}"
//   infra_ref         = local.infra_ref
//   import_type       = "LOCAL"
  
//   description = "Org-level experiment from enterprise template"
//   tags        = ["test", "terraform", "enterprise-org", "experiment"]

//   depends_on = [harness_chaos_experiment_template.org_level]
// }

# ============================================================================
# Test 9: Experiment Referencing Project-Level Template (COMMENTED OUT)
# ============================================================================
# REASON: Template 'project_level' doesn't exist
# TODO: Create project_level template or remove this test

// resource "harness_chaos_experiment" "enterprise_project_level" {
//   count = var.enable_experiment_enterprise_templates_test ? 1 : 0

//   org_id            = harness_platform_organization.this[0].id
//   project_id        = harness_platform_project.this[0].id
//   template_identity = length(harness_chaos_experiment_template.project_level) > 0 ? harness_chaos_experiment_template.project_level[0].identity : null
//   hub_identity      = harness_chaos_hub_v2.project_level[0].identity
//   name              = "Experiment-Enterprise-Project-${var.experiment_name_suffix}"
//   infra_ref         = local.infra_ref
//   import_type       = "REFERENCE"
  
//   description = "Project-level experiment from enterprise template"
//   tags        = ["test", "terraform", "enterprise-project", "experiment"]

//   depends_on = [harness_chaos_experiment_template.project_level]
// }

# ============================================================================
# Test 10: Multiple Experiments from Same Enterprise Template
# ============================================================================

resource "harness_chaos_experiment" "enterprise_instance_1" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id            = harness_platform_organization.this[0].id
  project_id        = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Instance-1-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"
  
  description = "First instance from enterprise template"
  tags        = ["test", "terraform", "enterprise-instance-1"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

resource "harness_chaos_experiment" "enterprise_instance_2" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id            = harness_platform_organization.this[0].id
  project_id        = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Instance-2-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"

  description = "Second instance from enterprise template"
  tags        = ["test", "terraform", "enterprise-instance-2"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

resource "harness_chaos_experiment" "enterprise_instance_3" {
  count = var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id            = harness_platform_organization.this[0].id
  project_id        = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Enterprise-Instance-3-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"  # Template reference

  
  description = "Third instance from enterprise template"
  tags        = ["test", "terraform", "enterprise-instance-3"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

# ============================================================================
# Outputs
# ============================================================================

output "experiment_enterprise_fault_id" {
  description = "ID of experiment from enterprise fault template"
  value       = length(harness_chaos_experiment.from_enterprise_fault) > 0 ? harness_chaos_experiment.from_enterprise_fault[0].id : null
}

output "experiment_enterprise_fault_identity" {
  description = "Identity of experiment from enterprise fault template"
  value       = length(harness_chaos_experiment.from_enterprise_fault) > 0 ? harness_chaos_experiment.from_enterprise_fault[0].identity : null
}

output "experiment_enterprise_parallel_id" {
  description = "ID of experiment with parallel fault and probe"
  value       = length(harness_chaos_experiment.from_enterprise_fault_probe_parallel) > 0 ? harness_chaos_experiment.from_enterprise_fault_probe_parallel[0].id : null
}

output "experiment_enterprise_two_probes_id" {
  description = "ID of experiment with two probes"
  value       = length(harness_chaos_experiment.from_enterprise_two_probes) > 0 ? harness_chaos_experiment.from_enterprise_two_probes[0].id : null
}

output "experiment_enterprise_action_id" {
  description = "ID of experiment with action"
  value       = length(harness_chaos_experiment.from_enterprise_with_action) > 0 ? harness_chaos_experiment.from_enterprise_with_action[0].id : null
}

output "experiment_enterprise_multi_fault_id" {
  description = "ID of experiment with multiple faults"
  value       = length(harness_chaos_experiment.from_enterprise_multi_fault) > 0 ? harness_chaos_experiment.from_enterprise_multi_fault[0].id : null
}

// output "experiment_enterprise_complex_id" {
//   description = "ID of most complex enterprise experiment"
//   value       = length(harness_chaos_experiment.from_enterprise_most_complex) > 0 ? harness_chaos_experiment.from_enterprise_most_complex[0].id : null
// }

// output "experiment_enterprise_account_level_id" {
//   description = "ID of account-level enterprise experiment"
//   value       = length(harness_chaos_experiment.enterprise_account_level) > 0 ? harness_chaos_experiment.enterprise_account_level[0].id : null
// }

// output "experiment_enterprise_org_level_id" {
//   description = "ID of org-level enterprise experiment"
//   value       = length(harness_chaos_experiment.enterprise_org_level) > 0 ? harness_chaos_experiment.enterprise_org_level[0].id : null
// }

// output "experiment_enterprise_project_level_id" {
//   description = "ID of project-level enterprise experiment"
//   value       = length(harness_chaos_experiment.enterprise_project_level) > 0 ? harness_chaos_experiment.enterprise_project_level[0].id : null
// }

output "experiment_enterprise_instance_1_id" {
  description = "ID of first enterprise experiment instance"
  value       = length(harness_chaos_experiment.enterprise_instance_1) > 0 ? harness_chaos_experiment.enterprise_instance_1[0].id : null
}

output "experiment_enterprise_instance_2_id" {
  description = "ID of second enterprise experiment instance"
  value       = length(harness_chaos_experiment.enterprise_instance_2) > 0 ? harness_chaos_experiment.enterprise_instance_2[0].id : null
}

output "experiment_enterprise_instance_3_id" {
  description = "ID of third enterprise experiment instance"
  value       = length(harness_chaos_experiment.enterprise_instance_3) > 0 ? harness_chaos_experiment.enterprise_instance_3[0].id : null
}
