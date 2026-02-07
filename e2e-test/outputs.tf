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
  value       = harness_chaos_hub_v2.account_level.id
}

output "chaos_hub_org_id" {
  description = "Org-level chaos hub ID"
  value       = harness_chaos_hub_v2.org_level.id
}

output "chaos_hub_project_id" {
  description = "Project-level chaos hub ID"
  value       = harness_chaos_hub_v2.project_level.id
}

# ----------------------------------------------------------------------------
# Template Outputs - Account Level
# ----------------------------------------------------------------------------
output "action_template_account_id" {
  description = "Account-level action template ID"
  value       = harness_chaos_action_template.account_level.id
}

output "probe_template_account_id" {
  description = "Account-level probe template ID"
  value       = harness_chaos_probe_template.account_level.id
}

output "fault_template_account_id" {
  description = "Account-level fault template ID"
  value       = harness_chaos_fault_template.account_level.id
}

output "experiment_template_account_custom_id" {
  description = "Account-level custom experiment template ID"
  value       = harness_chaos_experiment_template.account_custom.id
}

output "experiment_template_account_complex_id" {
  description = "Account-level complex experiment template ID"
  value       = harness_chaos_experiment_template.account_complex.id
}

# ----------------------------------------------------------------------------
# Template Outputs - Org Level
# ----------------------------------------------------------------------------
output "action_template_org_id" {
  description = "Org-level action template ID"
  value       = harness_chaos_action_template.org_level.id
}

output "probe_template_org_id" {
  description = "Org-level probe template ID"
  value       = harness_chaos_probe_template.org_level.id
}

output "fault_template_org_id" {
  description = "Org-level fault template ID"
  value       = harness_chaos_fault_template.org_level.id
}

output "experiment_template_org_custom_id" {
  description = "Org-level custom experiment template ID"
  value       = harness_chaos_experiment_template.org_custom.id
}

output "experiment_template_org_complex_id" {
  description = "Org-level complex experiment template ID"
  value       = harness_chaos_experiment_template.org_complex.id
}

# ----------------------------------------------------------------------------
# Template Outputs - Project Level
# ----------------------------------------------------------------------------
output "action_template_project_id" {
  description = "Project-level action template ID"
  value       = harness_chaos_action_template.project_level.id
}

output "probe_template_project_id" {
  description = "Project-level probe template ID"
  value       = harness_chaos_probe_template.project_level.id
}

output "fault_template_project_id" {
  description = "Project-level fault template ID"
  value       = harness_chaos_fault_template.project_level.id
}

output "experiment_template_project_custom_id" {
  description = "Project-level custom experiment template ID"
  value       = harness_chaos_experiment_template.project_custom.id
}

output "experiment_template_project_complex_id" {
  description = "Project-level complex experiment template ID"
  value       = harness_chaos_experiment_template.project_complex.id
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
  value       = harness_chaos_infrastructure_v2.this.id
}

output "infra_ref" {
  description = "Infrastructure reference (env_id/infra_id)"
  value       = local.infra_ref
}

output "service_discovery_agent_id" {
  description = "Service discovery agent ID"
  value       = harness_service_discovery_agent.this.id
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
  value       = harness_chaos_experiment.from_account_reference.id
}

output "experiment_from_account_reference_identity" {
  description = "Experiment from account complex template identity"
  value       = harness_chaos_experiment.from_account_reference.identity
}

output "experiment_from_account_local_id" {
  description = "Experiment from account complex template ID"
  value       = harness_chaos_experiment.from_account_local.id
}

output "experiment_from_account_local_identity" {
  description = "Experiment from account complex template identity"
  value       = harness_chaos_experiment.from_account_local.identity
}

# ----------------------------------------------------------------------------
# Experiment Outputs - Org Level
# ----------------------------------------------------------------------------
output "experiment_from_org_reference_id" {
  description = "Experiment from org complex template ID"
  value       = harness_chaos_experiment.from_org_reference.id
}

output "experiment_from_org_reference_identity" {
  description = "Experiment from org complex template identity"
  value       = harness_chaos_experiment.from_org_reference.identity
}

output "experiment_from_org_local_id" {
  description = "Experiment from org complex template ID"
  value       = harness_chaos_experiment.from_org_local.id
}

output "experiment_from_org_local_identity" {
  description = "Experiment from org complex template identity"
  value       = harness_chaos_experiment.from_org_local.identity
}

# ----------------------------------------------------------------------------
# Experiment Outputs - Project Level
# ----------------------------------------------------------------------------
output "experiment_from_project_reference_id" {
  description = "Experiment from project complex template ID"
  value       = harness_chaos_experiment.from_project_reference.id
}

output "experiment_from_project_reference_identity" {
  description = "Experiment from project complex template identity"
  value       = harness_chaos_experiment.from_project_reference.identity
}

output "experiment_from_project_local_identity" {
  description = "Experiment from project complex template identity"
  value       = harness_chaos_experiment.from_project_local.identity
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
      account = harness_chaos_hub_v2.account_level.identity
      org     = harness_chaos_hub_v2.org_level.identity
      project = harness_chaos_hub_v2.project_level.identity
    }
    
    templates = {
      account = {
        action            = harness_chaos_action_template.account_level.identity
        probe             = harness_chaos_probe_template.account_level.identity
        fault             = harness_chaos_fault_template.account_level.identity
        experiment_custom = harness_chaos_experiment_template.account_custom.identity
        experiment_complex = harness_chaos_experiment_template.account_complex.identity
      }
      org = {
        action            = harness_chaos_action_template.org_level.identity
        probe             = harness_chaos_probe_template.org_level.identity
        fault             = harness_chaos_fault_template.org_level.identity
        experiment_custom = harness_chaos_experiment_template.org_custom.identity
        experiment_complex = harness_chaos_experiment_template.org_complex.identity
      }
      project = {
        action            = harness_chaos_action_template.project_level.identity
        probe             = harness_chaos_probe_template.project_level.identity
        fault             = harness_chaos_fault_template.project_level.identity
        experiment_custom = harness_chaos_experiment_template.project_custom.identity
        experiment_complex = harness_chaos_experiment_template.project_complex.identity
      }
    }
    
    infrastructure = {
      environment       = harness_platform_environment.this.id
      platform_infra    = harness_platform_infrastructure.this.id
      chaos_infra       = harness_chaos_infrastructure_v2.this.id
      infra_ref         = local.infra_ref
    }
    
    experiments = {
      account_reference = harness_chaos_experiment.from_account_reference.identity
      org_reference     = harness_chaos_experiment.from_org_reference.identity
      project_reference = harness_chaos_experiment.from_project_reference.identity
      
      account_local = harness_chaos_experiment.from_account_local.identity
      org_local     = harness_chaos_experiment.from_org_local.identity
      project_local = harness_chaos_experiment.from_project_local.identity
    }
  }
}
