# ============================================================================
# Steps 5-9: Infrastructure Setup
# ============================================================================

# ----------------------------------------------------------------------------
# Step 5: Create Environment
# ----------------------------------------------------------------------------
resource "harness_platform_environment" "this" {
  depends_on = [
    harness_platform_project.this,
    harness_platform_connector_kubernetes.this
  ]

  identifier = var.environment_identifier
  name       = var.environment_name
  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  type       = "PreProduction"

  tags = local.tags_set
}

# ----------------------------------------------------------------------------
# Step 6: Create Platform Infrastructure
# ----------------------------------------------------------------------------
resource "harness_platform_infrastructure" "this" {
  depends_on = [
    harness_platform_environment.this,
    harness_platform_connector_kubernetes.this
  ]

  identifier      = var.infrastructure_identifier
  name            = var.infrastructure_name
  org_id          = harness_platform_organization.this.id
  project_id      = harness_platform_project.this.id
  env_id          = harness_platform_environment.this.id
  deployment_type = var.deployment_type
  type            = "KubernetesDirect"

  yaml = <<-EOT
  infrastructureDefinition:
    name: ${var.infrastructure_name}
    identifier: ${var.infrastructure_identifier}
    orgIdentifier: ${harness_platform_organization.this.id}
    projectIdentifier: ${harness_platform_project.this.id}
    environmentRef: ${harness_platform_environment.this.id}
    type: KubernetesDirect
    deploymentType: ${var.deployment_type}
    allowSimultaneousDeployments: false
    spec:
      connectorRef: ${harness_platform_connector_kubernetes.this.id}
      namespace: ${var.namespace}
      releaseName: release-${var.infrastructure_identifier}
  EOT

  tags = local.tags_set
}

# ----------------------------------------------------------------------------
# Step 7: Create Chaos Infrastructure V2
# ----------------------------------------------------------------------------
resource "harness_chaos_infrastructure_v2" "this" {
  count = local.create_infrastructure ? 1 : 0

  depends_on = [
    harness_platform_infrastructure.this
  ]

  org_id         = harness_platform_organization.this.id
  project_id     = harness_platform_project.this.id
  environment_id = harness_platform_environment.this.id
  infra_id       = harness_platform_infrastructure.this.id
  name           = var.chaos_infra_name
  infra_type     = var.chaos_infra_type

  # Flat schema (current provider implementation)
  namespace       = var.namespace
  service_account = var.chaos_service_account

  tags = var.chaos_infra_tags

  # ---------------------------------------------------------------------------
  # Image registry WITHOUT a custom_images block.
  #
  # Regression coverage for the infra-v2 update 500: the backend
  # (hce-saas pkg/imageregistry/repository.go) dereferences request.CustomImages
  # without a nil check, so omitting custom_images previously produced
  # "internal Server Error: error occurred while updating the infrastructure"
  # (status 500). Because this block is added to an already-applied infra, the
  # first re-apply exercises UpdateInfraV2 - the customer's exact scenario.
  #
  # is_private defaults to false so no real pull secret is required. To mirror
  # the customer config exactly, set is_private_registry = true and point
  # registry_secret_name at an existing secret.
  # ---------------------------------------------------------------------------
  image_registry {
    registry_server  = var.registry_server
    registry_account = var.registry_account
    is_private       = var.is_private_registry
    secret_name      = var.is_private_registry ? var.registry_secret_name : null
    # No custom_images block on purpose - this is what triggered the 500.
  }
}

# ----------------------------------------------------------------------------
# Step 8: Create Service Discovery Agent
# ----------------------------------------------------------------------------
resource "harness_service_discovery_agent" "this" {
  count = local.create_service_discovery ? 1 : 0

  depends_on = [
    harness_chaos_infrastructure_v2.this
  ]

  name                   = var.service_discovery_agent_name
  org_identifier         = harness_platform_organization.this.id
  project_identifier     = harness_platform_project.this.id
  environment_identifier = harness_platform_environment.this.id
  infra_identifier       = harness_platform_infrastructure.this.id
  installation_type      = var.sd_installation_type

  config {
    skip_secure_verify = false

    kubernetes {
      namespace       = var.sd_namespace
      service_account = var.sd_service_account
      run_as_user     = var.sd_run_as_user
      run_as_group    = var.sd_run_as_group
    }

    data {
      observed_namespaces      = var.sd_observed_namespaces
      enable_node_agent        = var.sd_enable_node_agent
      node_agent_selector      = var.sd_node_agent_selector
      collection_window_in_min = var.sd_collection_window_in_min

      cron {
        expression = var.sd_cron_expression
      }
    }
  }
}

# ----------------------------------------------------------------------------
# Step 9: Setup Chaos Image Registry (Optional)
# ----------------------------------------------------------------------------
# TEMPORARILY DISABLED - Testing with minimal config in test-image-registry.tf
