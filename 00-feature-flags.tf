# ============================================================================
# Feature Flags - Control What Resources to Create
# ============================================================================
# This file defines feature flags to control which resources are created
# during E2E testing. This makes it easy to test specific features or
# run partial tests without creating all resources.
#
# Usage:
#   1. Copy terraform.tfvars.example to terraform.tfvars
#   2. Set feature flags to true/false as needed
#   3. Run terraform apply
#
# Note: Base resources (org, project, connectors) are ALWAYS created
# ============================================================================

# ----------------------------------------------------------------------------
# Feature Flag Variables
# ----------------------------------------------------------------------------

variable "enable_chaos_hubs" {
  description = "Enable creation of chaos hubs at all scopes (account, org, project)"
  type        = bool
  default     = true
}

variable "enable_templates" {
  description = "Enable creation of all templates (action, probe, fault, experiment)"
  type        = bool
  default     = true
}

variable "enable_action_templates" {
  description = "Enable creation of action templates (requires enable_templates=true and enable_chaos_hubs=true)"
  type        = bool
  default     = true
}

variable "enable_probe_templates" {
  description = "Enable creation of probe templates (requires enable_templates=true and enable_chaos_hubs=true)"
  type        = bool
  default     = true
}

variable "enable_fault_templates" {
  description = "Enable creation of fault templates (requires enable_templates=true and enable_chaos_hubs=true)"
  type        = bool
  default     = true
}

variable "enable_experiment_templates" {
  description = "Enable creation of experiment templates (requires enable_templates=true and enable_chaos_hubs=true)"
  type        = bool
  default     = true
}

variable "enable_experiments" {
  description = "Enable creation of chaos experiments (requires enable_experiment_templates=true)"
  type        = bool
  default     = true
}

variable "enable_infrastructure" {
  description = "Enable creation of chaos infrastructure v2"
  type        = bool
  default     = true
}

variable "enable_image_registry" {
  description = "Enable creation of image registry configurations"
  type        = bool
  default     = true
}

variable "enable_service_discovery" {
  description = "Enable creation of service discovery agent"
  type        = bool
  default     = true
}

variable "enable_security_governance" {
  description = "Enable creation of security governance rules (V1 / GraphQL)"
  type        = bool
  default     = true
}

variable "enable_security_governance_v3" {
  description = "Enable creation of security governance V3 (REST) resources and namespace_labels tests"
  type        = bool
  default     = true
}

variable "enable_update_tests" {
  description = "Enable update test resources (probe template updates)"
  type        = bool
  default     = true
}

variable "enable_negative_tests" {
  description = "Enable negative test resources (expected to fail)"
  type        = bool
  default     = false
}

variable "enable_validation_tests" {
  description = "Enable validation test resources"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# Scope-Level Feature Flags
# ----------------------------------------------------------------------------

variable "enable_account_scope_resources" {
  description = "Enable account-level resources (hubs, templates)"
  type        = bool
  default     = true
}

variable "enable_org_scope_resources" {
  description = "Enable org-level resources (hubs, templates)"
  type        = bool
  default     = true
}

variable "enable_project_scope_resources" {
  description = "Enable project-level resources (hubs, templates)"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# Existing-Resource Reuse Flags
# ----------------------------------------------------------------------------

variable "use_existing_account_hub" {
  description = "If true, reference an existing account-level chaos hub (looked up by chaos_hub_account_identity) instead of creating a new one. Use this when an account-level hub already exists to avoid 'already exists' errors. Default false (create a new hub)."
  type        = bool
  default     = false
}

variable "use_existing_org_hub" {
  description = "If true, reference an existing org-level chaos hub (looked up by chaos_hub_org_identity) instead of creating a new one. Default false (create a new hub)."
  type        = bool
  default     = false
}

variable "use_existing_project_hub" {
  description = "If true, reference an existing project-level chaos hub (looked up by chaos_hub_project_identity) instead of creating a new one. Default false (create a new hub)."
  type        = bool
  default     = false
}

# ----------------------------------------------------------------------------
# Computed Flags (Internal Use)
# ----------------------------------------------------------------------------

locals {
  # Base resources are ALWAYS created (org, project, connectors)
  create_base_resources = true

  # Chaos hubs
  create_chaos_hubs = var.enable_chaos_hubs

  # Account hub: when enabled, either CREATE a new hub or REFERENCE an existing
  # one (controlled by var.use_existing_account_hub). account_hub_enabled is
  # true in either case and gates account-level templates/experiments.
  account_hub_enabled      = var.enable_chaos_hubs && var.enable_account_scope_resources
  create_account_hub       = local.account_hub_enabled && !var.use_existing_account_hub
  use_existing_account_hub = local.account_hub_enabled && var.use_existing_account_hub

  # Org hub: create a new one or reference an existing one.
  org_hub_enabled      = var.enable_chaos_hubs && var.enable_org_scope_resources
  create_org_hub       = local.org_hub_enabled && !var.use_existing_org_hub
  use_existing_org_hub = local.org_hub_enabled && var.use_existing_org_hub

  # Project hub: create a new one or reference an existing one.
  project_hub_enabled      = var.enable_chaos_hubs && var.enable_project_scope_resources
  create_project_hub       = local.project_hub_enabled && !var.use_existing_project_hub
  use_existing_project_hub = local.project_hub_enabled && var.use_existing_project_hub

  # Templates (require hubs)
  create_templates            = var.enable_templates && var.enable_chaos_hubs
  create_action_templates     = var.enable_templates && var.enable_action_templates && var.enable_chaos_hubs
  create_probe_templates      = var.enable_templates && var.enable_probe_templates && var.enable_chaos_hubs
  create_fault_templates      = var.enable_templates && var.enable_fault_templates && var.enable_chaos_hubs
  create_experiment_templates = var.enable_templates && var.enable_experiment_templates && var.enable_chaos_hubs

  # Scope-specific templates
  create_account_templates = local.create_templates && var.enable_account_scope_resources && local.account_hub_enabled
  create_org_templates     = local.create_templates && var.enable_org_scope_resources && local.org_hub_enabled
  create_project_templates = local.create_templates && var.enable_project_scope_resources && local.project_hub_enabled

  # Experiments (require experiment templates)
  create_experiments = var.enable_experiments && local.create_experiment_templates

  # Infrastructure
  create_infrastructure = var.enable_infrastructure

  # Image registry
  create_image_registry = var.enable_image_registry

  # Service discovery
  create_service_discovery = var.enable_service_discovery

  # Security governance
  create_security_governance    = var.enable_security_governance
  create_security_governance_v3 = var.enable_security_governance_v3

  # Test resources
  create_update_tests     = var.enable_update_tests && local.create_probe_templates
  create_negative_tests   = var.enable_negative_tests
  create_validation_tests = var.enable_validation_tests

  # ----------------------------------------------------------------------------
  # Helper Locals for Safe Resource References
  # ----------------------------------------------------------------------------
  # These provide safe references to resources that may or may not exist
  # Use these instead of direct resource references to avoid "Missing resource instance key" errors

  # Hub references (use [0] if created, empty string if not). The account hub
  # may be either created or referenced from an existing hub.
  account_hub_identity = local.create_account_hub ? harness_chaos_hub_v2.account_level[0].identity : (
    local.use_existing_account_hub ? data.harness_chaos_hub_v2.account_level_existing[0].identity : ""
  )
  org_hub_identity = local.create_org_hub ? harness_chaos_hub_v2.org_level[0].identity : (
    local.use_existing_org_hub ? data.harness_chaos_hub_v2.org_level_existing[0].identity : ""
  )
  project_hub_identity = local.create_project_hub ? harness_chaos_hub_v2.project_level[0].identity : (
    local.use_existing_project_hub ? data.harness_chaos_hub_v2.project_level_existing[0].identity : ""
  )

  account_hub_id = local.create_account_hub ? harness_chaos_hub_v2.account_level[0].id : (
    local.use_existing_account_hub ? data.harness_chaos_hub_v2.account_level_existing[0].id : ""
  )
  org_hub_id = local.create_org_hub ? harness_chaos_hub_v2.org_level[0].id : (
    local.use_existing_org_hub ? data.harness_chaos_hub_v2.org_level_existing[0].id : ""
  )
  project_hub_id = local.create_project_hub ? harness_chaos_hub_v2.project_level[0].id : (
    local.use_existing_project_hub ? data.harness_chaos_hub_v2.project_level_existing[0].id : ""
  )

  # Image registry references
  # Using test resources (one per scope)
  # Account-level registry is intentionally not managed in e2e (it mutates
  # shared account-wide settings), so this reference is left empty.
  account_image_registry_id = ""
  org_image_registry_id     = try(harness_chaos_image_registry.test_org_level.id, "")
  project_image_registry_id = try(harness_chaos_image_registry.test_project_level.id, "")

  # Template references (for outputs - return empty string if not created)
  action_template_account_id = local.create_action_templates && var.enable_account_scope_resources ? harness_chaos_action_template.account_level[0].id : ""
  probe_template_account_id  = local.create_probe_templates && var.enable_account_scope_resources ? harness_chaos_probe_template.account_level[0].id : ""
  fault_template_account_id  = local.create_fault_templates && var.enable_account_scope_resources ? harness_chaos_fault_template.account_level[0].id : ""

  action_template_org_id = local.create_action_templates && var.enable_org_scope_resources ? harness_chaos_action_template.org_level[0].id : ""
  probe_template_org_id  = local.create_probe_templates && var.enable_org_scope_resources ? harness_chaos_probe_template.org_level[0].id : ""
  fault_template_org_id  = local.create_fault_templates && var.enable_org_scope_resources ? harness_chaos_fault_template.org_level[0].id : ""

  action_template_project_id = local.create_action_templates && var.enable_project_scope_resources ? harness_chaos_action_template.project_level[0].id : ""
  probe_template_project_id  = local.create_probe_templates && var.enable_project_scope_resources ? harness_chaos_probe_template.project_level[0].id : ""
  fault_template_project_id  = local.create_fault_templates && var.enable_project_scope_resources ? harness_chaos_fault_template.project_level[0].id : ""

  exp_template_account_complex_id = local.create_experiment_templates && var.enable_account_scope_resources ? harness_chaos_experiment_template.account_complex[0].id : ""
  exp_template_org_complex_id     = local.create_experiment_templates && var.enable_org_scope_resources ? harness_chaos_experiment_template.org_complex[0].id : ""
  exp_template_project_complex_id = local.create_experiment_templates && var.enable_project_scope_resources ? harness_chaos_experiment_template.project_complex[0].id : ""

  exp_template_account_custom_id = local.create_experiment_templates && var.enable_account_scope_resources ? harness_chaos_experiment_template.account_custom[0].id : ""
  exp_template_org_custom_id     = local.create_experiment_templates && var.enable_org_scope_resources ? harness_chaos_experiment_template.org_custom[0].id : ""
  exp_template_project_custom_id = local.create_experiment_templates && var.enable_project_scope_resources ? harness_chaos_experiment_template.project_custom[0].id : ""

  # Experiment references
  exp_account_reference_id = local.create_experiments && var.enable_account_scope_resources ? harness_chaos_experiment.from_account_reference[0].id : ""
  exp_account_local_id     = local.create_experiments && var.enable_account_scope_resources ? harness_chaos_experiment.from_account_local[0].id : ""
  exp_org_reference_id     = local.create_experiments && var.enable_org_scope_resources ? harness_chaos_experiment.from_org_reference[0].id : ""
  exp_org_local_id         = local.create_experiments && var.enable_org_scope_resources ? harness_chaos_experiment.from_org_local[0].id : ""
  exp_project_reference_id = local.create_experiments && var.enable_project_scope_resources ? harness_chaos_experiment.from_project_reference[0].id : ""
  exp_project_local_id     = local.create_experiments && var.enable_project_scope_resources ? harness_chaos_experiment.from_project_local[0].id : ""

  # Experiment identities
  exp_account_reference_identity = local.create_experiments && var.enable_account_scope_resources ? harness_chaos_experiment.from_account_reference[0].identity : ""
  exp_account_local_identity     = local.create_experiments && var.enable_account_scope_resources ? harness_chaos_experiment.from_account_local[0].identity : ""
  exp_org_reference_identity     = local.create_experiments && var.enable_org_scope_resources ? harness_chaos_experiment.from_org_reference[0].identity : ""
  exp_org_local_identity         = local.create_experiments && var.enable_org_scope_resources ? harness_chaos_experiment.from_org_local[0].identity : ""
  exp_project_reference_identity = local.create_experiments && var.enable_project_scope_resources ? harness_chaos_experiment.from_project_reference[0].identity : ""
  exp_project_local_identity     = local.create_experiments && var.enable_project_scope_resources ? harness_chaos_experiment.from_project_local[0].identity : ""

  # Infrastructure
  chaos_infrastructure_v2_id = local.create_infrastructure ? harness_chaos_infrastructure_v2.this[0].id : ""

  # Service discovery and security governance
  service_discovery_agent_id       = local.create_service_discovery ? harness_service_discovery_agent.this[0].id : ""
  security_governance_condition_id = local.create_security_governance ? harness_chaos_security_governance_condition.this[0].id : ""
  security_governance_rule_id      = local.create_security_governance ? harness_chaos_security_governance_rule.this[0].id : ""

  # Template identities (for summary output)
  action_template_account_identity      = local.create_action_templates && var.enable_account_scope_resources ? harness_chaos_action_template.account_level[0].identity : ""
  probe_template_account_identity       = local.create_probe_templates && var.enable_account_scope_resources ? harness_chaos_probe_template.account_level[0].identity : ""
  fault_template_account_identity       = local.create_fault_templates && var.enable_account_scope_resources ? harness_chaos_fault_template.account_level[0].identity : ""
  exp_template_account_custom_identity  = local.create_experiment_templates && var.enable_account_scope_resources ? harness_chaos_experiment_template.account_custom[0].identity : ""
  exp_template_account_complex_identity = local.create_experiment_templates && var.enable_account_scope_resources ? harness_chaos_experiment_template.account_complex[0].identity : ""

  action_template_org_identity      = local.create_action_templates && var.enable_org_scope_resources ? harness_chaos_action_template.org_level[0].identity : ""
  probe_template_org_identity       = local.create_probe_templates && var.enable_org_scope_resources ? harness_chaos_probe_template.org_level[0].identity : ""
  fault_template_org_identity       = local.create_fault_templates && var.enable_org_scope_resources ? harness_chaos_fault_template.org_level[0].identity : ""
  exp_template_org_custom_identity  = local.create_experiment_templates && var.enable_org_scope_resources ? harness_chaos_experiment_template.org_custom[0].identity : ""
  exp_template_org_complex_identity = local.create_experiment_templates && var.enable_org_scope_resources ? harness_chaos_experiment_template.org_complex[0].identity : ""

  action_template_project_identity      = local.create_action_templates && var.enable_project_scope_resources ? harness_chaos_action_template.project_level[0].identity : ""
  probe_template_project_identity       = local.create_probe_templates && var.enable_project_scope_resources ? harness_chaos_probe_template.project_level[0].identity : ""
  fault_template_project_identity       = local.create_fault_templates && var.enable_project_scope_resources ? harness_chaos_fault_template.project_level[0].identity : ""
  exp_template_project_custom_identity  = local.create_experiment_templates && var.enable_project_scope_resources ? harness_chaos_experiment_template.project_custom[0].identity : ""
  exp_template_project_complex_identity = local.create_experiment_templates && var.enable_project_scope_resources ? harness_chaos_experiment_template.project_complex[0].identity : ""
}

# ----------------------------------------------------------------------------
# Feature Flag Status Output
# ----------------------------------------------------------------------------

output "feature_flags_status" {
  description = "Current feature flag configuration"
  value = {
    base_resources = {
      organization = "ALWAYS ENABLED"
      project      = "ALWAYS ENABLED"
      connectors   = "ALWAYS ENABLED"
    }
    chaos_hubs = {
      enabled     = var.enable_chaos_hubs
      account_hub = local.create_account_hub ? "CREATE" : (local.use_existing_account_hub ? "USE_EXISTING" : "DISABLED")
      org_hub     = local.create_org_hub ? "CREATE" : (local.use_existing_org_hub ? "USE_EXISTING" : "DISABLED")
      project_hub = local.create_project_hub ? "CREATE" : (local.use_existing_project_hub ? "USE_EXISTING" : "DISABLED")
    }
    templates = {
      enabled              = var.enable_templates
      action_templates     = local.create_action_templates
      probe_templates      = local.create_probe_templates
      fault_templates      = local.create_fault_templates
      experiment_templates = local.create_experiment_templates
    }
    experiments = {
      enabled = local.create_experiments
    }
    infrastructure = {
      chaos_infra_v2    = local.create_infrastructure
      service_discovery = local.create_service_discovery
      image_registry    = local.create_image_registry
    }
    security = {
      governance    = local.create_security_governance
      governance_v3 = local.create_security_governance_v3
    }
    tests = {
      update_tests     = local.create_update_tests
      negative_tests   = local.create_negative_tests
      validation_tests = local.create_validation_tests
    }
  }
}
