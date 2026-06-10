# ============================================================================
# Step 13: Preconditions and Postconditions
# ============================================================================
# Add lifecycle checks to critical resources to ensure proper dependencies
# and validate resource creation

# ----------------------------------------------------------------------------
# Precondition Checks for Experiments
# ----------------------------------------------------------------------------

# Null resource to validate infrastructure is ready before creating experiments
resource "null_resource" "validate_infrastructure_ready" {
  count = local.create_infrastructure ? 1 : 0
  
  depends_on = [
    harness_platform_environment.this,
    harness_platform_infrastructure.this,
    harness_chaos_infrastructure_v2.this
  ]

  lifecycle {
    precondition {
      condition     = harness_platform_environment.this.id != ""
      error_message = "Environment must be created before experiments"
    }

    precondition {
      condition     = harness_platform_infrastructure.this.id != ""
      error_message = "Platform infrastructure must be created before experiments"
    }

    precondition {
      condition     = try(harness_chaos_infrastructure_v2.this[0].id, "") != ""
      error_message = "Chaos infrastructure must be created before experiments"
    }

    precondition {
      condition     = local.infra_ref != ""
      error_message = "Infrastructure reference must be properly formatted"
    }
  }

  triggers = {
    env_id   = harness_platform_environment.this.id
    infra_id = harness_platform_infrastructure.this.id
    chaos_id = try(harness_chaos_infrastructure_v2.this[0].id, "")
  }
}

# ----------------------------------------------------------------------------
# Precondition Checks for Templates
# ----------------------------------------------------------------------------

# Validate hubs exist before creating templates
resource "null_resource" "validate_hubs_ready" {
  count = local.create_chaos_hubs ? 1 : 0

  depends_on = [
    harness_chaos_hub_v2.account_level,
    harness_chaos_hub_v2.org_level,
    harness_chaos_hub_v2.project_level
  ]

  lifecycle {
    precondition {
      condition     = local.account_hub_identity != ""
      error_message = "Account-level hub must be created before templates"
    }

    precondition {
      condition     = local.org_hub_identity != ""
      error_message = "Org-level hub must be created before templates"
    }

    precondition {
      condition     = local.project_hub_identity != ""
      error_message = "Project-level hub must be created before templates"
    }
  }

  triggers = {
    account_hub = local.account_hub_identity
    org_hub     = local.org_hub_identity
    project_hub = local.project_hub_identity
  }
}

# ----------------------------------------------------------------------------
# Precondition Checks for Experiment Templates
# ----------------------------------------------------------------------------

# Validate all templates exist before creating experiment templates
resource "null_resource" "validate_templates_ready" {
  count = local.create_templates ? 1 : 0

  depends_on = [
    harness_chaos_action_template.account_level,
    harness_chaos_probe_template.account_level,
    harness_chaos_fault_template.account_level,
    harness_chaos_action_template.org_level,
    harness_chaos_probe_template.org_level,
    harness_chaos_fault_template.org_level,
    harness_chaos_action_template.project_level,
    harness_chaos_probe_template.project_level,
    harness_chaos_fault_template.project_level
  ]

  lifecycle {
    precondition {
      condition = (
        local.action_template_account_identity != "" &&
        local.probe_template_account_identity != "" &&
        local.fault_template_account_identity != ""
      )
      error_message = "All account-level templates must be created before experiment templates"
    }

    precondition {
      condition = (
        local.action_template_org_identity != "" &&
        local.probe_template_org_identity != "" &&
        local.fault_template_org_identity != ""
      )
      error_message = "All org-level templates must be created before experiment templates"
    }

    precondition {
      condition = (
        local.action_template_project_identity != "" &&
        local.probe_template_project_identity != "" &&
        local.fault_template_project_identity != ""
      )
      error_message = "All project-level templates must be created before experiment templates"
    }
  }

  triggers = {
    account_action = local.action_template_account_identity
    account_probe  = local.probe_template_account_identity
    account_fault  = local.fault_template_account_identity
    org_action     = local.action_template_org_identity
    org_probe      = local.probe_template_org_identity
    org_fault      = local.fault_template_org_identity
    project_action = local.action_template_project_identity
    project_probe  = local.probe_template_project_identity
    project_fault  = local.fault_template_project_identity
  }
}

# ----------------------------------------------------------------------------
# Postcondition Checks
# ----------------------------------------------------------------------------

# Validate organization and project were created successfully
resource "null_resource" "validate_foundation" {
  depends_on = [
    harness_platform_organization.this,
    harness_platform_project.this
  ]

  lifecycle {
    postcondition {
      condition     = harness_platform_organization.this.id != ""
      error_message = "Failed to create organization"
    }

    postcondition {
      condition     = harness_platform_project.this.id != ""
      error_message = "Failed to create project"
    }

    postcondition {
      condition     = harness_platform_organization.this.id == var.org_identifier
      error_message = "Organization ID does not match expected identifier"
    }

    postcondition {
      condition     = harness_platform_project.this.id == var.project_identifier
      error_message = "Project ID does not match expected identifier"
    }
  }

  triggers = {
    org_id     = harness_platform_organization.this.id
    project_id = harness_platform_project.this.id
  }
}

# Validate all hubs were created with correct identities
resource "null_resource" "validate_hubs_created" {
  count = local.create_chaos_hubs ? 1 : 0

  depends_on = [
    harness_chaos_hub_v2.account_level,
    harness_chaos_hub_v2.org_level,
    harness_chaos_hub_v2.project_level
  ]

  lifecycle {
    postcondition {
      condition     = local.account_hub_identity == var.chaos_hub_account_identity
      error_message = "Account hub identity does not match expected value"
    }

    postcondition {
      condition     = local.org_hub_identity == var.chaos_hub_org_identity
      error_message = "Org hub identity does not match expected value"
    }

    postcondition {
      condition     = local.project_hub_identity == var.chaos_hub_project_identity
      error_message = "Project hub identity does not match expected value"
    }
  }

  triggers = {
    account_hub = local.account_hub_identity
    org_hub     = local.org_hub_identity
    project_hub = local.project_hub_identity
  }
}

# Validate infrastructure reference format
resource "null_resource" "validate_infra_ref_format" {
  depends_on = [
    harness_platform_environment.this,
    harness_platform_infrastructure.this
  ]

  lifecycle {
    postcondition {
      condition     = can(regex("^[^/]+/[^/]+$", local.infra_ref))
      error_message = "Infrastructure reference must be in format: env_id/infra_id"
    }

    postcondition {
      condition     = split("/", local.infra_ref)[0] == harness_platform_environment.this.id
      error_message = "Infrastructure reference environment ID does not match"
    }

    postcondition {
      condition     = split("/", local.infra_ref)[1] == harness_platform_infrastructure.this.id
      error_message = "Infrastructure reference infrastructure ID does not match"
    }
  }

  triggers = {
    infra_ref = local.infra_ref
  }
}

# Validate experiments were created with correct import types
resource "null_resource" "validate_experiment_import_types" {
  count = local.create_experiments ? 1 : 0
  
  depends_on = [
    harness_chaos_experiment.from_project_reference,
    harness_chaos_experiment.from_project_local
  ]

  lifecycle {
    postcondition {
      condition     = try(harness_chaos_experiment.from_project_reference[0].import_type, "") == "REFERENCE"
      error_message = "Project REFERENCE experiment has incorrect import type"
    }

    postcondition {
      condition     = try(harness_chaos_experiment.from_project_local[0].import_type, "") == "LOCAL"
      error_message = "Project LOCAL experiment has incorrect import type"
    }

    postcondition {
      condition = (
        try(harness_chaos_experiment.from_project_reference[0].template_identity, "") ==
        local.exp_template_project_complex_identity
      )
      error_message = "REFERENCE experiment template identity does not match"
    }

    postcondition {
      condition = (
        try(harness_chaos_experiment.from_project_local[0].template_identity, "") ==
        local.exp_template_project_complex_identity
      )
      error_message = "LOCAL experiment template identity does not match"
    }
  }

  triggers = {
    ref_import_type   = try(harness_chaos_experiment.from_project_reference[0].import_type, "")
    local_import_type = try(harness_chaos_experiment.from_project_local[0].import_type, "")
  }
}

# ----------------------------------------------------------------------------
# Precondition/Postcondition Summary Output
# ----------------------------------------------------------------------------
output "precondition_postcondition_summary" {
  description = "Summary of all precondition and postcondition checks"
  value = {
    foundation_validated = {
      organization_id_correct = harness_platform_organization.this.id == var.org_identifier
      project_id_correct      = harness_platform_project.this.id == var.project_identifier
    }
    hubs_validated = {
      account_hub_identity_correct = local.account_hub_identity == var.chaos_hub_account_identity
      org_hub_identity_correct     = local.org_hub_identity == var.chaos_hub_org_identity
      project_hub_identity_correct = local.project_hub_identity == var.chaos_hub_project_identity
    }
    infrastructure_validated = {
      infra_ref_format_correct = can(regex("^[^/]+/[^/]+$", local.infra_ref))
      env_id_matches           = split("/", local.infra_ref)[0] == harness_platform_environment.this.id
      infra_id_matches         = split("/", local.infra_ref)[1] == harness_platform_infrastructure.this.id
    }
    experiments_validated = {
      reference_import_type_correct = try(harness_chaos_experiment.from_project_reference[0].import_type, "") == "REFERENCE"
      local_import_type_correct     = try(harness_chaos_experiment.from_project_local[0].import_type, "") == "LOCAL"
    }
    all_checks_passed = (
      harness_platform_organization.this.id == var.org_identifier &&
      harness_platform_project.this.id == var.project_identifier &&
      local.account_hub_identity == var.chaos_hub_account_identity &&
      can(regex("^[^/]+/[^/]+$", local.infra_ref)) &&
      try(harness_chaos_experiment.from_project_reference[0].import_type, "") == "REFERENCE" &&
      try(harness_chaos_experiment.from_project_local[0].import_type, "") == "LOCAL"
    )
  }
}
