output "organization_id" {
  description = "The ID of the organization"
  value       = local.org_id
}

output "project_id" {
  description = "The ID of the project"
  value       = local.project_id
}

output "environment_id" {
  description = "The ID of the environment"
  value       = harness_platform_environment.this.id
}

output "kubernetes_connector_id" {
  description = "The ID of the Kubernetes connector"
  value       = harness_platform_connector_kubernetes.this.id
}

output "infrastructure_id" {
  description = "The ID of the infrastructure definition"
  value       = harness_platform_infrastructure.this.id
}

output "org_chaos_image_registry_id" {
  description = "The ID of the organization level Chaos Image Registry"
  value       = try(harness_chaos_image_registry.org_level[0].id, null)
}

output "project_chaos_image_registry_id" {
  description = "The ID of the project level Chaos Image Registry"
  value       = try(harness_chaos_image_registry.project_level[0].id, null)
}

output "chaos_infrastructure_id" {
  description = "The ID of the Chaos Infrastructure"
  value       = harness_chaos_infrastructure_v2.this.id
}

output "service_discovery_agent_id" {
  description = "The ID of the Service Discovery Agent"
  value       = harness_service_discovery_agent.this.id
}

output "chaos_hub_id" {
  description = "The ID of the Chaos Hub"
  value       = var.create_chaos_hub ? harness_chaos_hub.this[0].id : null
}

output "security_governance_condition_id" {
  description = "The ID of the Security Governance Condition"
  value       = harness_chaos_security_governance_condition.this.id
}

output "security_governance_rule_id" {
  description = "The ID of the Security Governance Rule"
  value       = harness_chaos_security_governance_rule.this.id
}

output "chaos_hub_v2_account_level_id" {
  description = "The ID of the Chaos Hub V2 Account Level"
  value       = var.create_chaos_hub_v2_account_level ? harness_chaos_hub_v2.account_level[0].id : null
}

output "chaos_hub_v2_org_level_id" {
  description = "The ID of the Chaos Hub V2 Org Level"
  value       = var.create_chaos_hub_v2_org_level ? harness_chaos_hub_v2.org_level[0].id : null
}

output "chaos_hub_v2_project_level_id" {
  description = "The ID of the Chaos Hub V2 Project Level"
  value       = var.create_chaos_hub_v2_project_level ? harness_chaos_hub_v2.project_level[0].id : null
}
