# ============================================================================
# Variable Validation Rules
# ============================================================================
# Additional variables with validation rules for E2E testing

# ----------------------------------------------------------------------------
# Testing Control Variables
# ----------------------------------------------------------------------------
variable "run_negative_tests" {
  description = "Enable negative test scenarios (tests that should fail)"
  type        = bool
  default     = false
}

variable "test_cross_scope_violations" {
  description = "Test cross-scope permission violations"
  type        = bool
  default     = false
}

variable "test_duplicate_resources" {
  description = "Test duplicate resource creation (should fail)"
  type        = bool
  default     = false
}

variable "enable_drift_testing" {
  description = "Enable drift testing scenarios"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# Enhanced Validation Rules
# ----------------------------------------------------------------------------

# Validate delegate selectors
locals {
  validate_delegate_selectors = var.delegate_selectors != null && length(var.delegate_selectors) > 0
}

# Validate namespace format (Kubernetes naming convention)
locals {
  validate_namespace = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
}

# Validate identifiers (no spaces, lowercase with underscores)
locals {
  validate_org_identifier     = can(regex("^[a-z0-9_]+$", var.org_identifier))
  validate_project_identifier = can(regex("^[a-z0-9_]+$", var.project_identifier))
}

# Validate chaos infrastructure type
locals {
  valid_chaos_infra_types   = ["KUBERNETESV2", "LINUX", "WINDOWS"]
  validate_chaos_infra_type = contains(local.valid_chaos_infra_types, var.chaos_infra_type)
}

# Validate deployment type
locals {
  valid_deployment_types   = ["Kubernetes", "NativeHelm", "ServerlessAwsLambda", "AzureWebApp"]
  validate_deployment_type = contains(local.valid_deployment_types, var.deployment_type)
}

# Validate service discovery installation type
locals {
  valid_sd_types       = ["KUBERNETES", "DOCKER", "CONNECTOR"]
  validate_sd_type = contains(local.valid_sd_types, var.sd_installation_type)
}

# Validate project color (hex color format)
locals {
  validate_project_color = can(regex("^#[0-9A-Fa-f]{6}$", var.project_color))
}

# Validate security governance condition operator
locals {
  valid_operators             = ["IN", "NOT_IN", "EQUALS", "NOT_EQUALS"]
  validate_condition_operator = contains(local.valid_operators, var.security_governance_condition_operator)
}

# Validate security governance condition infrastructure type
locals {
  valid_infra_types             = ["KubernetesV2", "Linux", "Windows"]
  validate_condition_infra_type = contains(local.valid_infra_types, var.security_governance_condition_infra_type)
}

# ----------------------------------------------------------------------------
# Validation Outputs (for debugging)
# ----------------------------------------------------------------------------
output "validation_checks" {
  description = "Results of variable validation checks"
  value = {
    delegate_selectors_valid = local.validate_delegate_selectors
    namespace_valid          = local.validate_namespace
    org_identifier_valid     = local.validate_org_identifier
    project_identifier_valid = local.validate_project_identifier
    chaos_infra_type_valid   = local.validate_chaos_infra_type
    deployment_type_valid    = local.validate_deployment_type
    sd_type_valid            = local.validate_sd_type
    project_color_valid      = local.validate_project_color
    condition_operator_valid = local.validate_condition_operator
    all_validations_passed = (
      local.validate_delegate_selectors &&
      local.validate_namespace &&
      local.validate_org_identifier &&
      local.validate_project_identifier &&
      local.validate_chaos_infra_type &&
      local.validate_deployment_type &&
      local.validate_sd_type &&
      local.validate_project_color &&
      local.validate_condition_operator
    )
  }
}
