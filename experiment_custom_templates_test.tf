# Experiment Tests - Custom Templates
# This file tests creating experiments from experiment templates that use CUSTOM templates
# (custom fault templates, probe templates, and action templates)

# Enable this test by setting the variable
variable "enable_experiment_custom_templates_test" {
  description = "Enable experiment tests with custom templates"
  type        = bool
  default     = false
}

# ============================================================================
# Test 1: Experiment from Custom Fault Template
# ============================================================================

resource "harness_chaos_experiment" "from_custom_fault" {
  count = var.enable_experiment_custom_templates_test ? 1 : 0

  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = length(harness_chaos_experiment_template.custom_fault_simple) > 0 ? harness_chaos_experiment_template.custom_fault_simple[0].identity : null
  hub_identity      = var.hub_identity
  name              = "Experiment-Custom-Fault-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"  # Template reference (default) - updates propagate
  
  description = "Experiment created from custom fault template (REFERENCE import)"
  tags        = ["test", "terraform", "custom-fault", "experiment", "reference"]

  depends_on = [harness_chaos_experiment_template.custom_fault_simple]
}

# ============================================================================
# Test 2: Experiment from Custom Fault + Action + Probe Template
# ============================================================================

resource "harness_chaos_experiment" "from_custom_all" {
  count = var.enable_experiment_custom_templates_test ? 1 : 0

  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = length(harness_chaos_experiment_template.custom_fault_with_action_probe) > 0 ? harness_chaos_experiment_template.custom_fault_with_action_probe[0].identity : null
  hub_identity      = var.hub_identity
  name              = "Experiment-Custom-All-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"  # Template reference
  
  description = "Experiment with custom fault, action, and probe templates (REFERENCE)"
  tags        = ["test", "terraform", "custom-all", "experiment", "reference"]

  depends_on = [harness_chaos_experiment_template.custom_fault_with_action_probe]
}

# ============================================================================
# Test 3: Experiment from Everything Custom Template
# ============================================================================

resource "harness_chaos_experiment" "from_everything_custom" {
  count = var.enable_experiment_custom_templates_test ? 1 : 0

  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = length(harness_chaos_experiment_template.everything_custom) > 0 ? harness_chaos_experiment_template.everything_custom[0].identity : null
  hub_identity      = var.hub_identity
  name              = "Experiment-Everything-Custom-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"  # Full copy - independent of template changes
  
  description = "Experiment with all custom templates (LOCAL import - full copy)"
  tags        = ["test", "terraform", "everything-custom", "experiment", "local"]

  depends_on = [harness_chaos_experiment_template.everything_custom]
}

# ============================================================================
# Test 4: Experiment with Runtime Inputs
# ============================================================================

resource "harness_chaos_experiment" "with_runtime_inputs" {
  count = var.enable_experiment_custom_templates_test ? 1 : 0

  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = length(harness_chaos_experiment_template.custom_fault_simple) > 0 ? harness_chaos_experiment_template.custom_fault_simple[0].identity : null
  hub_identity      = var.hub_identity
  name              = "Experiment-Runtime-Inputs-${var.experiment_name_suffix}"
  infra_ref         = "<+input>" # Runtime input for infrastructure
  import_type       = "REFERENCE"  # Template reference
  
  description = "Experiment with runtime inputs for flexibility (REFERENCE)"
  tags        = ["test", "terraform", "runtime-inputs", "experiment", "reference"]

  depends_on = [harness_chaos_experiment_template.custom_fault_simple]
}

# ============================================================================
# Test 5: Multiple Experiments from Same Template
# ============================================================================

resource "harness_chaos_experiment" "instance_1" {
  count = var.enable_experiment_custom_templates_test ? 1 : 0

  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = length(harness_chaos_experiment_template.custom_fault_simple) > 0 ? harness_chaos_experiment_template.custom_fault_simple[0].identity : null
  hub_identity      = var.hub_identity
  name              = "Experiment-Instance-1-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"  # Both instances use REFERENCE
  
  description = "First instance of experiment from same template (REFERENCE)"
  tags        = ["test", "terraform", "instance-1", "reference"]

  depends_on = [harness_chaos_experiment_template.custom_fault_simple]
}

resource "harness_chaos_experiment" "instance_2" {
  count = var.enable_experiment_custom_templates_test ? 1 : 0

  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = length(harness_chaos_experiment_template.custom_fault_simple) > 0 ? harness_chaos_experiment_template.custom_fault_simple[0].identity : null
  hub_identity      = var.hub_identity
  name              = "Experiment-Instance-2-${var.experiment_name_suffix}"
  infra_ref         = local.infra_ref
  import_type       = "LOCAL"  # This instance uses LOCAL for comparison
  
  description = "Second instance of experiment from same template (LOCAL - independent copy)"
  tags        = ["test", "terraform", "instance-2", "local"]

  depends_on = [harness_chaos_experiment_template.custom_fault_simple]
}

# ============================================================================
# Outputs
# ============================================================================

output "experiment_custom_fault_id" {
  description = "ID of experiment created from custom fault template"
  value       = length(harness_chaos_experiment.from_custom_fault) > 0 ? harness_chaos_experiment.from_custom_fault[0].id : null
}

output "experiment_custom_fault_identity" {
  description = "Identity of experiment created from custom fault template"
  value       = length(harness_chaos_experiment.from_custom_fault) > 0 ? harness_chaos_experiment.from_custom_fault[0].identity : null
}

output "experiment_custom_all_id" {
  description = "ID of experiment with all custom templates"
  value       = length(harness_chaos_experiment.from_custom_all) > 0 ? harness_chaos_experiment.from_custom_all[0].id : null
}

output "experiment_everything_custom_id" {
  description = "ID of experiment with everything custom"
  value       = length(harness_chaos_experiment.from_everything_custom) > 0 ? harness_chaos_experiment.from_everything_custom[0].id : null
}

output "experiment_runtime_inputs_id" {
  description = "ID of experiment with runtime inputs"
  value       = length(harness_chaos_experiment.with_runtime_inputs) > 0 ? harness_chaos_experiment.with_runtime_inputs[0].id : null
}

output "experiment_instance_1_id" {
  description = "ID of first experiment instance"
  value       = length(harness_chaos_experiment.instance_1) > 0 ? harness_chaos_experiment.instance_1[0].id : null
}

output "experiment_instance_2_id" {
  description = "ID of second experiment instance"
  value       = length(harness_chaos_experiment.instance_2) > 0 ? harness_chaos_experiment.instance_2[0].id : null
}
