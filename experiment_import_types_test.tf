# Experiment Import Type Tests
# This file tests REFERENCE vs LOCAL import types

# Enable this test by setting the variable
variable "enable_experiment_import_types_test" {
  description = "Enable experiment import type tests (REFERENCE vs LOCAL) - requires enable_experiment_enterprise_templates_test=true"
  type        = bool
  default     = true
}

# ============================================================================
# Test 1: REFERENCE Import (Template Reference) - Default
# ============================================================================

resource "harness_chaos_experiment" "reference_import" {
  count = var.enable_experiment_import_types_test && var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity
  template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
  name              = "Experiment-Reference-Import-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"  # Template reference (default)
  
  description = "Experiment with REFERENCE import - references template, no manifest copy"
  tags        = ["test", "terraform", "reference-import"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

# ============================================================================
# Test 2: LOCAL Import (Full Copy)
# ============================================================================

resource "harness_chaos_experiment" "local_import" {
  count = var.enable_experiment_import_types_test && var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity
  template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
  name              = "Experiment-Local-Import-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"  # Full copy with manifest
  
  description = "Experiment with LOCAL import - full copy of template with manifest"
  tags        = ["test", "terraform", "local-import"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

# ============================================================================
# Test 3: Experiment Referencing Account-Level Template (COMMENTED OUT)
# ============================================================================
# REASON: Template 'account_level' doesn't exist
# TODO: Create account_level template or remove this test

// resource "harness_chaos_experiment" "account_level_reference" {
//   count = var.enable_experiment_import_types_test && var.enable_experiment_enterprise_templates_test ? 1 : 0

//   org_id       = harness_platform_organization.this[0].id
//   project_id   = harness_platform_project.this[0].id
//   hub_identity = harness_chaos_hub_v2.account_level[0].identity
//   template_identity = length(harness_chaos_experiment_template.account_level) > 0 ? harness_chaos_experiment_template.account_level[0].identity : null
//   name              = "Experiment-Ref-Account-Template-${var.experiment_name_suffix}"
//   infra_ref         = local.infra_ref
//   import_type       = "REFERENCE"
  
//   description = "Project-level experiment referencing account-level template (REFERENCE)"
//   tags        = ["test", "terraform", "ref-account-template", "reference"]

//   depends_on = [harness_chaos_experiment_template.account_level]
// }

# ============================================================================
# Test 4: Experiment Referencing Org-Level Template (COMMENTED OUT)
# ============================================================================
# REASON: Template 'org_level' doesn't exist
# TODO: Create org_level template or remove this test

// resource "harness_chaos_experiment" "org_level_reference" {
//   count = var.enable_experiment_import_types_test && var.enable_experiment_enterprise_templates_test ? 1 : 0

//   org_id       = harness_platform_organization.this[0].id
//   project_id   = harness_platform_project.this[0].id
//   hub_identity = harness_chaos_hub_v2.org_level[0].identity
//   template_identity = length(harness_chaos_experiment_template.org_level) > 0 ? harness_chaos_experiment_template.org_level[0].identity : null
//   name              = "Experiment-Ref-Org-Template-${var.experiment_name_suffix}"
//   infra_ref         = local.infra_ref
//   import_type       = "REFERENCE"
  
//   description = "Project-level experiment referencing org-level template (REFERENCE)"
//   tags        = ["test", "terraform", "ref-org-template", "reference"]

//   depends_on = [harness_chaos_experiment_template.org_level]
// }

# ============================================================================
# Test 5: Experiment Referencing Project-Level Template (COMMENTED OUT)
# ============================================================================
# REASON: Template 'project_level' doesn't exist
# TODO: Create project_level template or remove this test

// resource "harness_chaos_experiment" "project_level_local" {
//   count = var.enable_experiment_import_types_test && var.enable_experiment_enterprise_templates_test ? 1 : 0

//   org_id       = harness_platform_organization.this[0].id
//   project_id   = harness_platform_project.this[0].id
//   hub_identity = harness_chaos_hub_v2.project_level[0].identity
//   template_identity = length(harness_chaos_experiment_template.project_level) > 0 ? harness_chaos_experiment_template.project_level[0].identity : null
//   name              = "Experiment-Ref-Project-Template-${var.experiment_name_suffix}"
//   infra_ref         = local.infra_ref
//   import_type       = "LOCAL"
  
//   description = "Project-level experiment referencing project-level template (LOCAL)"
//   tags        = ["test", "terraform", "ref-project-template", "local"]

//   depends_on = [harness_chaos_experiment_template.project_level]
// }

# ============================================================================
# Test 6: Verify Template Updates Don't Affect REFERENCE Experiments
# ============================================================================

# This experiment uses REFERENCE import, so template updates should propagate
resource "harness_chaos_experiment" "reference_propagates_updates" {
  count = var.enable_experiment_import_types_test && var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity
  template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
  name              = "Experiment-Reference-Updates-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"
  
  description = "REFERENCE import - template updates propagate to this experiment"
  tags        = ["test", "terraform", "reference", "updates"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

# ============================================================================
# Test 7: Verify Template Updates Don't Affect LOCAL Experiments
# ============================================================================

# This experiment uses LOCAL import, so it's independent of template changes
resource "harness_chaos_experiment" "local_independent" {
  count = var.enable_experiment_import_types_test && var.enable_experiment_enterprise_templates_test ? 1 : 0

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
  hub_identity = harness_chaos_hub_v2.project_level[0].identity
  name              = "Experiment-Local-Independent-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"
  
  description = "LOCAL import - independent of template changes (full copy)"
  tags        = ["test", "terraform", "local", "independent"]

  depends_on = [harness_chaos_experiment_template.simple_fault_only]
}

# ============================================================================
# Outputs
# ============================================================================

output "reference_import_id" {
  description = "ID of REFERENCE import experiment"
  value       = length(harness_chaos_experiment.reference_import) > 0 ? harness_chaos_experiment.reference_import[0].id : null
}

output "reference_import_has_template_details" {
  description = "REFERENCE import should have template_details"
  value       = length(harness_chaos_experiment.reference_import) > 0 ? length(harness_chaos_experiment.reference_import[0].template_details) > 0 : null
}

output "local_import_id" {
  description = "ID of LOCAL import experiment"
  value       = length(harness_chaos_experiment.local_import) > 0 ? harness_chaos_experiment.local_import[0].id : null
}

output "local_import_has_manifest" {
  description = "LOCAL import should have manifest"
  value       = length(harness_chaos_experiment.local_import) > 0 ? length(harness_chaos_experiment.local_import[0].manifest) > 0 : null
}

// output "account_level_reference_id" {
//   description = "ID of account-level REFERENCE experiment"
//   value       = length(harness_chaos_experiment.account_level_reference) > 0 ? harness_chaos_experiment.account_level_reference[0].id : null
// }

// output "org_level_reference_id" {
//   description = "ID of org-level REFERENCE experiment"
//   value       = length(harness_chaos_experiment.org_level_reference) > 0 ? harness_chaos_experiment.org_level_reference[0].id : null
// }

// output "project_level_local_id" {
//   description = "ID of project-level LOCAL experiment"
//   value       = length(harness_chaos_experiment.project_level_local) > 0 ? harness_chaos_experiment.project_level_local[0].id : null
// }

# ============================================================================
# Verification Notes
# ============================================================================

# After running these tests, verify:
#
# 1. REFERENCE Import (reference_import):
#    - template_details block is populated
#    - manifest field is empty
#    - Hub reference format correct for scope
#
# 2. LOCAL Import (local_import):
#    - manifest field is populated with YAML
#    - template_details block is empty/null
#    - Full experiment definition stored
#
# 3. Scope-Based Hub References:
#    - Account level: hub reference = "account.{hub_identity}"
#    - Org level: hub reference = "org.{hub_identity}"
#    - Project level: hub reference = "{hub_identity}" (no prefix)
#
# 4. Template Update Behavior:
#    - REFERENCE: Updates to template propagate to experiment
#    - LOCAL: Experiment is independent, template updates don't affect it
#
# Run with:
#   export TF_VAR_enable_experiment_import_types_test=true
#   export TF_VAR_infra_ref="your-k8s-infra-id"
#   terraform apply -auto-approve
