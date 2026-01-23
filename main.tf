locals {
  // Use provided org_identifier or create a new one
  org_id = var.org_identifier != null ? var.org_identifier : harness_platform_organization.this[0].id

  // Use provided project_identifier or create a new one
  project_id = var.project_identifier != null ? var.project_identifier : (
    var.org_identifier != null ? "${var.org_identifier}_${replace(lower(var.project_name), " ", "_")}" :
    "${harness_platform_organization.this[0].id}_${replace(lower(var.project_name), " ", "_")}"
  )

  // Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      "module" = "harness-chaos-engineering"
    }
  )

  // Convert tags map to set of strings for resources that require it
  tags_set = [for k, v in local.common_tags : "${k}=${v}"]
}

// 1. Create Organization (if not provided)
resource "harness_platform_organization" "this" {
  count       = var.org_identifier == null ? 1 : 0
  identifier  = replace(lower(var.org_name), " ", "_")
  name        = var.org_name
  description = "Organization for Chaos Engineering"
  tags        = local.tags_set
}

// 2. Create Project (if not provided)
resource "harness_platform_project" "this" {
  depends_on = [
    harness_platform_organization.this
  ]

  count       = var.project_identifier == null ? 1 : 0
  org_id      = local.org_id
  identifier  = local.project_id
  name        = var.project_name
  color       = var.project_color
  description = "Project for Chaos Engineering"
  tags        = local.tags_set # Using the converted tags set
}

// 3. Create Kubernetes Connector
resource "harness_platform_connector_kubernetes" "this" {
  depends_on = [
    harness_platform_project.this
  ]

  identifier = var.k8s_connector_name
  name       = var.k8s_connector_name
  org_id     = local.org_id
  project_id = local.project_id

  inherit_from_delegate {
    delegate_selectors = var.delegate_selectors
  }

  tags = local.tags_set # Using the converted tags set
}

// 4. Create Environment
resource "harness_platform_environment" "this" {
  depends_on = [
    harness_platform_project.this,
    harness_platform_connector_kubernetes.this
  ]

  identifier = var.environment_identifier
  name       = var.environment_name
  org_id     = local.org_id
  project_id = local.project_id
  type       = "PreProduction"

  tags = local.tags_set # Using the converted tags set
}

// 5. Create Infrastructure Definition
resource "harness_platform_infrastructure" "this" {
  depends_on = [
    harness_platform_environment.this,
    harness_platform_connector_kubernetes.this
  ]

  identifier      = var.infrastructure_identifier
  name            = var.infrastructure_name
  org_id          = local.org_id
  project_id      = local.project_id
  env_id          = harness_platform_environment.this.id
  deployment_type = var.deployment_type
  type            = "KubernetesDirect"

  yaml = <<-EOT
  infrastructureDefinition:
    name: ${var.infrastructure_name}
    identifier: ${var.infrastructure_identifier}
    orgIdentifier: ${local.org_id}
    projectIdentifier: ${local.project_id}
    environmentRef: ${harness_platform_environment.this.id}
    type: KubernetesDirect
    deploymentType: ${var.deployment_type}
    allowSimultaneousDeployments: false
    spec:
      connectorRef: ${var.k8s_connector_name}
      namespace: ${var.namespace}
      releaseName: release-${var.infrastructure_identifier}
  EOT

  tags = local.tags_set # Using the converted tags set
}

// 6. Create Chaos Image Registry at Organization Level (if private registry)
resource "harness_chaos_image_registry" "org_level" {
  depends_on = [
    harness_platform_organization.this
  ]

  count = var.setup_custom_registry ? 1 : 0

  org_id = local.org_id

  // Registry details
  registry_server  = var.registry_server
  registry_account = var.registry_account

  is_default          = var.is_default_registry
  is_override_allowed = var.is_override_allowed
  is_private          = var.is_private_registry
  secret_name         = var.registry_secret_name != "" ? var.registry_secret_name : null

  // Custom images if needed
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

// 7. Setup Chaos Image Registry at Project Level (if private registry)
resource "harness_chaos_image_registry" "project_level" {
  depends_on = [
    harness_chaos_image_registry.org_level
  ]

  count = var.setup_custom_registry ? 1 : 0

  org_id     = local.org_id
  project_id = local.project_id

  // Registry details
  registry_server  = var.registry_server
  registry_account = var.registry_account

  // Authentication
  is_default          = var.is_default_registry
  is_override_allowed = var.is_override_allowed
  is_private          = var.is_private_registry
  secret_name         = var.registry_secret_name != "" ? var.registry_secret_name : null

  // Custom images if needed
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

// 8. Create Chaos Infrastructure V2
resource "harness_chaos_infrastructure_v2" "this" {
  depends_on = [
    harness_platform_infrastructure.this
  ]

  // Required fields
  org_id         = local.org_id
  project_id     = local.project_id
  environment_id = harness_platform_environment.this.id
  infra_id       = harness_platform_infrastructure.this.id
  name           = var.chaos_infra_name
  description    = var.chaos_infra_description

  // Optional fields
  namespace  = var.chaos_infra_namespace
  infra_type = var.chaos_infra_type

  ai_enabled           = var.chaos_ai_enabled
  insecure_skip_verify = var.chaos_insecure_skip_verify

  service_account = var.service_account_name
  tags            = local.tags_set
}

// 9. Create Service Discovery Agent
resource "harness_service_discovery_agent" "this" {
  depends_on = [
    harness_chaos_infrastructure_v2.this
  ]

  name                   = var.service_discovery_agent_name
  org_identifier         = local.org_id
  project_identifier     = local.project_id
  environment_identifier = harness_platform_environment.this.id
  infra_identifier       = harness_platform_infrastructure.this.id
  installation_type      = var.sd_installation_type

  config {
    kubernetes {
      namespace = var.sd_namespace
    }
  }
}

// 10.1 Create Git Connector (if enabled)
resource "harness_platform_connector_git" "chaos_hub" {
  depends_on = [
    harness_platform_organization.this,
    harness_platform_project.this
  ]

  count = var.create_git_connector ? 1 : 0

  identifier  = replace(lower(var.git_connector_name), " ", "-")
  name        = var.git_connector_name
  description = "Git connector for Chaos Hub"
  org_id      = local.org_id
  project_id  = local.project_id
  url         = var.git_connector_url

  // Connection type (required)
  connection_type = "Account" // or "Repo" depending on your needs

  // Determine authentication type based on provided credentials
  dynamic "credentials" {
    for_each = var.git_connector_ssh_key != "" ? [1] : []
    content {
      ssh {
        ssh_key_ref = var.git_connector_ssh_key
      }
    }
  }

  // HTTP/HTTPS authentication
  dynamic "credentials" {
    for_each = var.git_connector_ssh_key == "" ? [1] : []
    content {
      http {
        username     = var.git_connector_username != "" ? var.git_connector_username : null
        password_ref = var.git_connector_password != "" ? var.git_connector_password : null

        // For GitHub apps
        dynamic "github_app" {
          for_each = var.github_app_id != "" ? [1] : []
          content {
            application_id  = var.github_app_id
            installation_id = var.github_installation_id
            private_key_ref = var.github_private_key_ref
          }
        }
      }
    }
  }

  // Validation configuration
  validation_repo = var.git_connector_validation_repo

  // Tags - ensure chaos_hub_tags is a map
  tags = merge(
    { for k, v in var.chaos_hub_tags : k => v },
    {
      "managed_by" = "terraform"
      "purpose"    = "chaos-hub-git-connector"
    }
  )
}

// 10.2 Create Chaos Hub
resource "harness_chaos_hub" "this" {
  depends_on = [
    harness_platform_connector_git.chaos_hub
  ]

  count = var.create_chaos_hub ? 1 : 0

  org_id      = local.org_id
  project_id  = local.project_id
  name        = var.chaos_hub_name
  description = var.chaos_hub_description

  // Use the created connector ID or the provided one
  connector_id    = var.create_git_connector ? one(harness_platform_connector_git.chaos_hub[*].id) : var.chaos_hub_connector_id
  repo_branch     = var.chaos_hub_repo_branch
  repo_name       = var.chaos_hub_repo_name
  is_default      = var.chaos_hub_is_default
  connector_scope = var.chaos_hub_connector_scope

  tags = var.chaos_hub_tags

  // Add common tags to the resource
  lifecycle {
    ignore_changes = [
      // Ignore changes to tags as they may be modified outside of Terraform
      tags,
    ]
  }
}

// 10.3 Create Chaos Hub
resource "harness_chaos_hub_v2" "account_level" {
  # Ensure this hub is deleted AFTER project_level hub to satisfy API requirement
  # "at least one hub must exist in project"
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.create_chaos_hub_v2_account_level ? 1 : 0

  identity    = var.chaos_hub_v2_account_level_identity
  name        = var.chaos_hub_v2_account_level_name
  description = var.chaos_hub_description

  tags = var.chaos_hub_tags

  // Add common tags to the resource
  lifecycle {
    ignore_changes = [
      // Ignore changes to tags as they may be modified outside of Terraform
      tags,
    ]
  }
}

resource "harness_chaos_hub_v2" "org_level" {
  # Ensure this hub is deleted AFTER project_level hub to satisfy API requirement
  # "at least one hub must exist in project"
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.create_chaos_hub_v2_org_level ? 1 : 0

  org_id      = local.org_id
  identity    = var.chaos_hub_v2_org_level_identity
  name        = var.chaos_hub_v2_org_level_name
  description = var.chaos_hub_description

  tags = var.chaos_hub_tags

  // Add common tags to the resource
  lifecycle {
    ignore_changes = [
      // Ignore changes to tags as they may be modified outside of Terraform
      tags,
    ]
  }
}

resource "harness_chaos_hub_v2" "project_level" {
  count = var.create_chaos_hub_v2_project_level ? 1 : 0

  org_id      = local.org_id
  project_id  = local.project_id
  identity    = var.chaos_hub_v2_project_level_identity
  name        = var.chaos_hub_v2_project_level_name
  description = var.chaos_hub_description

  tags = var.chaos_hub_tags

  // Add common tags to the resource
  lifecycle {
    ignore_changes = [
      // Ignore changes to tags as they may be modified outside of Terraform
      tags,
    ]
  }
}

// 11. Create Security Governance Condition
resource "harness_chaos_security_governance_condition" "this" {
  depends_on = [
    harness_platform_environment.this,
    harness_platform_infrastructure.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = var.security_governance_condition_name
  description = "Condition to block destructive experiments"
  org_id      = local.org_id
  project_id  = local.project_id

  // Required fields - Set the appropriate infra_type based on your needs
  infra_type = var.security_governance_condition_infra_type

  // Fault specifications
  fault_spec {
    operator = var.security_governance_condition_operator

    dynamic "faults" {
      for_each = var.security_governance_condition_faults
      content {
        fault_type = faults.value.fault_type
        name       = faults.value.name
      }
    }
  }

  // Kubernetes specific specifications (only for KubernetesV2 infra_type)
  dynamic "k8s_spec" {
    for_each = var.security_governance_condition_infra_type == "KubernetesV2" ? [1] : []
    content {
      infra_spec {
        operator  = var.security_governance_condition_infra_operator
        infra_ids = ["${harness_platform_environment.this.id}/${harness_chaos_infrastructure_v2.this.id}"]
      }

      // Application specification (optional)
      dynamic "application_spec" {
        for_each = var.security_governance_condition_application_spec != null ? [1] : []
        content {
          operator = var.security_governance_condition_application_spec.operator

          dynamic "workloads" {
            for_each = var.security_governance_condition_application_spec.workloads
            content {
              namespace = workloads.value.namespace
              kind      = workloads.value.kind
            }
          }
        }
      }

      // Chaos service account specification (optional)
      dynamic "chaos_service_account_spec" {
        for_each = var.security_governance_condition_service_account_spec != null ? [1] : []
        content {
          operator         = var.security_governance_condition_service_account_spec.operator
          service_accounts = var.security_governance_condition_service_account_spec.service_accounts
        }
      }
    }
  }

  // Machine specifications (for Windows/Linux infra_type)
  dynamic "machine_spec" {
    for_each = contains(["Windows", "Linux"], var.security_governance_condition_infra_type) ? [1] : []
    content {
      infra_spec {
        operator  = var.security_governance_condition_infra_operator
        infra_ids = var.security_governance_condition_infra_ids
      }
    }
  }

  // Lifecycle to handle name changes
  lifecycle {
    ignore_changes = [name]
  }

  # Convert merged tags to list of strings format
  tags = [
    for k, v in merge(
      local.common_tags,
      {
        "platform" = lower(var.security_governance_condition_infra_type)
      }
    ) : "${k}=${v}"
  ]
}

// 12. Create Security Governance Rule
resource "harness_chaos_security_governance_rule" "this" {
  depends_on = [
    harness_chaos_security_governance_condition.this
  ]

  name        = var.security_governance_rule_name
  description = var.security_governance_rule_description
  org_id      = local.org_id
  project_id  = local.project_id
  is_enabled  = var.security_governance_rule_is_enabled

  // Required fields
  condition_ids  = [harness_chaos_security_governance_condition.this.id]
  user_group_ids = var.security_governance_rule_user_group_ids

  // Time window configuration
  dynamic "time_windows" {
    for_each = var.security_governance_rule_time_windows
    content {
      time_zone  = time_windows.value.time_zone
      start_time = time_windows.value.start_time
      duration   = time_windows.value.duration

      dynamic "recurrence" {
        for_each = time_windows.value.recurrence != null ? [time_windows.value.recurrence] : []
        content {
          type  = recurrence.value.type
          until = recurrence.value.until
        }
      }
    }
  }

  // Lifecycle to handle name changes
  lifecycle {
    ignore_changes = [name]
  }

  # Convert merged tags to list of strings format
  tags = [
    for k, v in merge(
      local.common_tags,
      {
        "platform" = lower(var.security_governance_condition_infra_type)
      }
    ) : "${k}=${v}"
  ]
}
