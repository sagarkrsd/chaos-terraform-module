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
}

# ----------------------------------------------------------------------------
# Step 8: Create Service Discovery Agent
# ----------------------------------------------------------------------------
resource "harness_service_discovery_agent" "this" {
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
    kubernetes {
      namespace = var.sd_namespace
    }
  }
}

# ----------------------------------------------------------------------------
# Step 9: Setup Chaos Image Registry (Optional)
# ----------------------------------------------------------------------------
resource "harness_chaos_image_registry" "project_level" {
  count = var.setup_custom_registry ? 1 : 0

  depends_on = [
    harness_platform_project.this
  ]

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id

  # Registry details
  registry_server  = var.registry_server
  registry_account = var.registry_account

  # Authentication
  is_default          = var.is_default_registry
  is_override_allowed = var.is_override_allowed
  is_private          = var.is_private_registry
  secret_name         = var.registry_secret_name != "" ? var.registry_secret_name : null

  # Custom images if needed
  use_custom_images = var.use_custom_images
  dynamic "custom_images" {
    for_each = var.use_custom_images ? [1] : []
    content {
      log_watcher = var.log_watcher_image != "" ? var.log_watcher_image : null
      ddcr        = var.ddcr_image != "" ? var.ddcr_image : null
      ddcr_lib    = var.ddcr_lib_image != "" ? var.ddcr_lib_image : null
      ddcr_fault  = var.ddcr_fault_image != "" ? var.ddcr_fault_image : null
    }
  }
}
