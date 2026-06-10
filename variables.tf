# ============================================================================
# Variables for E2E Chaos Engineering Test
# ============================================================================

# ----------------------------------------------------------------------------
# Foundation Variables
# ----------------------------------------------------------------------------
variable "org_identifier" {
  description = "Organization identifier"
  type        = string
  default     = "chaos_e2e_test_org"
}

variable "org_name" {
  description = "Organization name"
  type        = string
  default     = "Chaos E2E Test Org"
}

variable "project_identifier" {
  description = "Project identifier"
  type        = string
  default     = "chaos_e2e_test_project"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Chaos E2E Test Project"
}

variable "project_color" {
  description = "Project color"
  type        = string
  default     = "#0063F7"
}

# ----------------------------------------------------------------------------
# Connector Variables
# ----------------------------------------------------------------------------
variable "k8s_connector_identifier" {
  description = "Kubernetes connector identifier"
  type        = string
  default     = "chaos_e2e_k8s_connector"
}

variable "k8s_connector_name" {
  description = "Kubernetes connector name"
  type        = string
  default     = "Chaos E2E K8s Connector"
}

variable "delegate_selectors" {
  description = "Delegate selectors"
  type        = list(string)
  default     = ["chaos-delegate"]
}

# ----------------------------------------------------------------------------
# Chaos Hub Variables
# ----------------------------------------------------------------------------
variable "chaos_hub_account_identity" {
  description = "Account-level chaos hub identity"
  type        = string
  default     = "e2e_chaos_hub_account"
}

variable "chaos_hub_account_name" {
  description = "Account-level chaos hub name"
  type        = string
  default     = "E2E Chaos Hub Account"
}

variable "chaos_hub_org_identity" {
  description = "Org-level chaos hub identity"
  type        = string
  default     = "e2e_chaos_hub_org"
}

variable "chaos_hub_org_name" {
  description = "Org-level chaos hub name"
  type        = string
  default     = "E2E Chaos Hub Org"
}

variable "chaos_hub_project_identity" {
  description = "Project-level chaos hub identity"
  type        = string
  default     = "e2e_chaos_hub_project"
}

variable "chaos_hub_project_name" {
  description = "Project-level chaos hub name"
  type        = string
  default     = "E2E Chaos Hub Project"
}

variable "chaos_hub_tags" {
  description = "Tags for chaos hubs"
  type        = list(string)
  default     = ["e2e", "test", "chaos-hub"]
}

# ----------------------------------------------------------------------------
# Infrastructure Variables
# ----------------------------------------------------------------------------
variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = "chaos_e2e_env"
}

variable "environment_name" {
  description = "Environment name"
  type        = string
  default     = "Chaos E2E Environment"
}

variable "infrastructure_identifier" {
  description = "Infrastructure identifier"
  type        = string
  default     = "chaos_e2e_infra"
}

variable "infrastructure_name" {
  description = "Infrastructure name"
  type        = string
  default     = "Chaos E2E Infrastructure"
}

variable "deployment_type" {
  description = "Deployment type"
  type        = string
  default     = "Kubernetes"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "chaos-e2e"
}

variable "chaos_infra_name" {
  description = "Chaos infrastructure name"
  type        = string
  default     = "Chaos E2E Infrastructure V2"
}

variable "chaos_infra_type" {
  description = "Chaos infrastructure type"
  type        = string
  default     = "KUBERNETESV2"
}

variable "chaos_service_account" {
  description = "Chaos service account"
  type        = string
  default     = "litmus"
}

variable "chaos_infra_tags" {
  description = "Tags for chaos infrastructure"
  type        = list(string)
  default     = ["e2e", "test", "kubernetes"]
}

# ----------------------------------------------------------------------------
# Service Discovery Variables
# ----------------------------------------------------------------------------
variable "sd_installation_type" {
  description = "Service discovery installation type"
  type        = string
  default     = "CONNECTOR"
}

variable "service_discovery_agent_name" {
  description = "Service discovery agent name"
  type        = string
  default     = "Chaos E2E Service Discovery Agent"
}

variable "sd_namespace" {
  description = "Service discovery namespace"
  type        = string
  default     = "chaos-e2e"
}

variable "sd_service_account" {
  description = "Service account for the service discovery agent (empty = default)"
  type        = string
  default     = ""
}

variable "sd_run_as_user" {
  description = "UID the service discovery agent runs as"
  type        = number
  default     = 2000
}

variable "sd_run_as_group" {
  description = "GID the service discovery agent runs as"
  type        = number
  default     = 2000
}

variable "sd_observed_namespaces" {
  description = "Namespaces observed by the service discovery agent"
  type        = list(string)
  default     = ["boutique"]
}

variable "sd_enable_node_agent" {
  description = "Whether the service discovery node agent is enabled"
  type        = bool
  default     = true
}

variable "sd_node_agent_selector" {
  description = "Node selector for the service discovery node agent (empty = none)"
  type        = string
  default     = ""
}

variable "sd_collection_window_in_min" {
  description = "Data collection window in minutes for service discovery"
  type        = number
  default     = 5
}

variable "sd_cron_expression" {
  description = "Cron expression for service discovery data collection"
  type        = string
  default     = "0/15 * * * *"
}

# ----------------------------------------------------------------------------
# Image Registry Variables (Optional)
# ----------------------------------------------------------------------------
variable "setup_custom_registry" {
  description = "Setup custom image registry"
  type        = bool
  default     = false
}

variable "registry_server" {
  description = "Registry server URL"
  type        = string
  default     = "docker.io"
}

variable "registry_account" {
  description = "Registry account/username"
  type        = string
  default     = "harness"
}

variable "is_default_registry" {
  description = "Set as default registry"
  type        = bool
  default     = true
}

variable "is_override_allowed" {
  description = "Allow override of registry"
  type        = bool
  default     = true
}

variable "is_private_registry" {
  description = "Is private registry"
  type        = bool
  default     = false
}

variable "registry_secret_name" {
  description = "Secret name for registry authentication"
  type        = string
  default     = "harness-registry-secret"
}

variable "use_custom_images" {
  description = "Use custom images"
  type        = bool
  default     = false
}

variable "log_watcher_image" {
  description = "Custom image for log watcher"
  type        = string
  default     = "docker.io/harness/chaos-log-watcher:1.88.0"
}

variable "ddcr_image" {
  description = "Custom image for DDCR (Dedicated Data Collection and Reporting)"
  type        = string
  default     = "docker.io/harness/chaos-ddcr:1.88.0"
}

variable "ddcr_lib_image" {
  description = "Custom image for DDCR library"
  type        = string
  default     = "docker.io/harness/chaos-ddcr-faults:1.88.0"
}

variable "ddcr_fault_image" {
  description = "Custom image for DDCR fault injection"
  type        = string
  default     = "docker.io/harness/chaos-ddcr-faults:1.88.0"
}

# ----------------------------------------------------------------------------
# Security Governance Variables
# ----------------------------------------------------------------------------
variable "security_governance_condition_name" {
  description = "Security governance condition name"
  type        = string
  default     = "e2e-security-condition"
}

variable "security_governance_condition_infra_type" {
  description = "Type of infrastructure (KubernetesV2, Windows, Linux)"
  type        = string
  default     = "KubernetesV2"
  validation {
    condition     = contains(["KubernetesV2", "Windows", "Linux"], var.security_governance_condition_infra_type)
    error_message = "Infrastructure type must be one of: KubernetesV2, Windows, Linux"
  }
}

variable "security_governance_condition_operator" {
  description = "Operator for the fault specification"
  type        = string
  default     = "NOT_EQUAL_TO"
}

variable "security_governance_condition_faults" {
  description = "List of faults to include in the condition"
  type = list(object({
    fault_type = string
    name       = string
  }))
  default = [
    {
      fault_type = "FAULT"
      name       = "*"
    }
  ]
}

// variable "security_governance_condition_faults" {
//   description = "List of faults to include in the condition"
//   type = list(object({
//     fault_type = string
//     name       = string
//   }))
//   default = [
//     {
//       fault_type = "FAULT"
//       name       = "pod-delete"
//     },
//     {
//       fault_type = "FAULT"
//       name       = "container-kill"
//     },
//     {
//       fault_type = "FAULT"
//       name       = "pod-network-loss"
//     }
//   ]
// }

variable "security_governance_condition_infra_operator" {
  description = "Operator for the infrastructure specification"
  type        = string
  default     = "EQUAL_TO"
}

variable "security_governance_condition_infra_ids" {
  description = "List of infrastructure IDs to apply the condition to"
  type        = list(string)
  default     = []
}

variable "security_governance_condition_application_spec" {
  description = "Application specification for Kubernetes conditions"
  type = object({
    operator = string
    workloads = list(object({
      namespace          = string
      kind               = string
      label              = string
      services           = list(string)
      application_map_id = string
    }))
  })
  default = {
    operator = "EQUAL_TO"
    workloads = [
      {
        namespace          = "boutique"
        kind               = "deployment"
        label              = "app=adservice"
        services           = ["adservice"]
        application_map_id = ""
      }
    ]
  }
}

variable "security_governance_condition_service_account_spec" {
  description = "Service account specification for Kubernetes conditions"
  type = object({
    operator         = string
    service_accounts = list(string)
  })
  default = {
    operator         = "EQUAL_TO"
    service_accounts = ["*"]
  }
}

variable "security_governance_rule_name" {
  description = "Name of the security governance rule"
  type        = string
  default     = "deny-destructive-experiments-rule"
}

variable "security_governance_rule_description" {
  description = "Description of the security governance rule"
  type        = string
  default     = "Rule to block destructive experiments"
}

variable "security_governance_rule_action" {
  description = "Action to take when the rule is matched"
  type        = string
  default     = "DENY"
}

variable "security_governance_rule_is_enabled" {
  description = "Whether the security governance rule is enabled"
  type        = bool
  default     = true
}

variable "security_governance_rule_user_group_ids" {
  description = "List of user group IDs to apply the rule to"
  type        = list(string)
  default     = ["_project_all_users"]
}

variable "security_governance_rule_time_windows" {
  description = "List of time windows for the rule"
  type = list(object({
    time_zone  = string
    start_time = number
    end_time   = number
    recurrence = object({
      type  = string
      until = number
    })
  }))
  default = [
    {
      time_zone  = "UTC"
      start_time = 1781072073000
      # end_time must be within one year of start_time (chaos guard rule).
      # 1781072073000 + ~360 days (31,104,000,000 ms) = 1812176073000.
      end_time   = 1812176073000
      recurrence = {
        type  = "Daily"
        until = -1
      }
    }
  ]
}
