# ============================================================================
# Outputs for E2E Chaos Engineering Test
# ============================================================================

# ----------------------------------------------------------------------------
# Foundation Outputs
# ----------------------------------------------------------------------------
output "org_id" {
  description = "Organization ID"
  value       = harness_platform_organization.this.id
}

output "project_id" {
  description = "Project ID"
  value       = harness_platform_project.this.id
}

# ----------------------------------------------------------------------------
# Chaos Hub Outputs
# ----------------------------------------------------------------------------
output "chaos_hub_account_id" {
  description = "Account-level chaos hub ID"
  value       = local.account_hub_id
}

output "chaos_hub_org_id" {
  description = "Org-level chaos hub ID"
  value       = local.org_hub_id
}

output "chaos_hub_project_id" {
  description = "Project-level chaos hub ID"
  value       = local.project_hub_id
}

# ----------------------------------------------------------------------------
# Template Outputs - Account Level
# ----------------------------------------------------------------------------
output "action_template_account_id" {
  description = "Account-level action template ID"
  value       = local.action_template_account_id
}

output "probe_template_account_id" {
  description = "Account-level probe template ID"
  value       = local.probe_template_account_id
}

output "fault_template_account_id" {
  description = "Account-level fault template ID"
  value       = local.fault_template_account_id
}

output "experiment_template_account_custom_id" {
  description = "Account-level custom experiment template ID"
  value       = local.exp_template_account_custom_id
}

output "experiment_template_account_complex_id" {
  description = "Account-level complex experiment template ID"
  value       = local.exp_template_account_complex_id
}

# ----------------------------------------------------------------------------
# Template Outputs - Org Level
# ----------------------------------------------------------------------------
output "action_template_org_id" {
  description = "Org-level action template ID"
  value       = local.action_template_org_id
}

output "probe_template_org_id" {
  description = "Org-level probe template ID"
  value       = local.probe_template_org_id
}

output "fault_template_org_id" {
  description = "Org-level fault template ID"
  value       = local.fault_template_org_id
}

output "experiment_template_org_custom_id" {
  description = "Org-level custom experiment template ID"
  value       = local.exp_template_org_custom_id
}

output "experiment_template_org_complex_id" {
  description = "Org-level complex experiment template ID"
  value       = local.exp_template_org_complex_id
}

# ----------------------------------------------------------------------------
# Template Outputs - Project Level
# ----------------------------------------------------------------------------
output "action_template_project_id" {
  description = "Project-level action template ID"
  value       = local.action_template_project_id
}

output "probe_template_project_id" {
  description = "Project-level probe template ID"
  value       = local.probe_template_project_id
}

output "fault_template_project_id" {
  description = "Project-level fault template ID"
  value       = local.fault_template_project_id
}

output "experiment_template_project_custom_id" {
  description = "Project-level custom experiment template ID"
  value       = local.exp_template_project_custom_id
}

output "experiment_template_project_complex_id" {
  description = "Project-level complex experiment template ID"
  value       = local.exp_template_project_complex_id
}

# ----------------------------------------------------------------------------
# Infrastructure Outputs
# ----------------------------------------------------------------------------
output "environment_id" {
  description = "Environment ID"
  value       = harness_platform_environment.this.id
}

output "infrastructure_id" {
  description = "Platform infrastructure ID"
  value       = harness_platform_infrastructure.this.id
}

output "chaos_infrastructure_id" {
  description = "Chaos infrastructure V2 ID"
  value       = local.chaos_infrastructure_v2_id
}

output "infra_ref" {
  description = "Infrastructure reference (env_id/infra_id)"
  value       = local.infra_ref
}

output "service_discovery_agent_id" {
  description = "Service discovery agent ID"
  value       = local.service_discovery_agent_id
}

output "image_registry_org_id" {
  description = "Image registry organization ID"
  value       = local.org_image_registry_id
}

output "image_registry_project_id" {
  description = "Image registry project ID"
  value       = local.project_image_registry_id
}

# ----------------------------------------------------------------------------
# Security Governance Outputs
# ----------------------------------------------------------------------------
// output "security_governance_condition_id" {
//   description = "Security governance condition ID"
//   value       = harness_chaos_security_governance_condition.this.id
// }

// output "security_governance_rule_id" {
//   description = "Security governance rule ID"
//   value       = harness_chaos_security_governance_rule.this.id
// }

# ----------------------------------------------------------------------------
# Experiment Outputs - Account Level
# ----------------------------------------------------------------------------
output "experiment_from_account_reference_id" {
  description = "Experiment from account complex template ID"
  value       = local.exp_account_reference_id
}

output "experiment_from_account_reference_identity" {
  description = "Experiment from account complex template identity"
  value       = local.exp_account_reference_identity
}

output "experiment_from_account_local_id" {
  description = "Experiment from account complex template ID"
  value       = local.exp_account_local_id
}

output "experiment_from_account_local_identity" {
  description = "Experiment from account complex template identity"
  value       = local.exp_account_local_identity
}

# ----------------------------------------------------------------------------
# Experiment Outputs - Org Level
# ----------------------------------------------------------------------------
output "experiment_from_org_reference_id" {
  description = "Experiment from org complex template ID"
  value       = local.exp_org_reference_id
}

output "experiment_from_org_reference_identity" {
  description = "Experiment from org complex template identity"
  value       = local.exp_org_reference_identity
}

output "experiment_from_org_local_id" {
  description = "Experiment from org complex template ID"
  value       = local.exp_org_local_id
}

output "experiment_from_org_local_identity" {
  description = "Experiment from org complex template identity"
  value       = local.exp_org_local_identity
}

# ----------------------------------------------------------------------------
# Experiment Outputs - Project Level
# ----------------------------------------------------------------------------
output "experiment_from_project_reference_id" {
  description = "Experiment from project complex template ID"
  value       = local.exp_project_reference_id
}

output "experiment_from_project_reference_identity" {
  description = "Experiment from project complex template identity"
  value       = local.exp_project_reference_identity
}

output "experiment_from_project_local_identity" {
  description = "Experiment from project complex template identity"
  value       = local.exp_project_local_identity
}

# ----------------------------------------------------------------------------
# Summary Output
# ----------------------------------------------------------------------------
output "summary" {
  description = "Summary of created resources"
  value = {
    organization = harness_platform_organization.this.id
    project      = harness_platform_project.this.id

    chaos_hubs = {
      account = local.account_hub_identity
      org     = local.org_hub_identity
      project = local.project_hub_identity
    }

    templates = {
      account = {
        action             = local.action_template_account_identity
        probe              = local.probe_template_account_identity
        fault              = local.fault_template_account_identity
        experiment_custom  = local.exp_template_account_custom_identity
        experiment_complex = local.exp_template_account_complex_identity
      }
      org = {
        action             = local.action_template_org_identity
        probe              = local.probe_template_org_identity
        fault              = local.fault_template_org_identity
        experiment_custom  = local.exp_template_org_custom_identity
        experiment_complex = local.exp_template_org_complex_identity
      }
      project = {
        action             = local.action_template_project_identity
        probe              = local.probe_template_project_identity
        fault              = local.fault_template_project_identity
        experiment_custom  = local.exp_template_project_custom_identity
        experiment_complex = local.exp_template_project_complex_identity
      }
    }

    infrastructure = {
      environment    = harness_platform_environment.this.id
      platform_infra = harness_platform_infrastructure.this.id
      chaos_infra    = local.chaos_infrastructure_v2_id
      infra_ref      = local.infra_ref
    }

    experiments = {
      account_reference = local.exp_account_reference_identity
      org_reference     = local.exp_org_reference_identity
      project_reference = local.exp_project_reference_identity

      account_local = local.exp_account_local_identity
      org_local     = local.exp_org_local_identity
      project_local = local.exp_project_local_identity
    }
  }
}
