
// Organization Variables
variable "org_identifier" {
  description = "Organization identifier. If not provided, a new organization will be created"
  type        = string
  default     = null
}

variable "org_name" {
  description = "Name of the organization to create (if org_identifier is not provided)"
  type        = string
  default     = "chaos terraform demo"
}

// Project Variables
variable "project_identifier" {
  description = "Project identifier. If not provided, a new project will be created"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name of the project to create (if project_identifier is not provided)"
  type        = string
  default     = "chaos terraform demo"
}

variable "project_color" {
  description = "Color code for the project"
  type        = string
  default     = "#0063F7"
}

// Kubernetes Connector Variables
variable "k8s_connector_name" {
  description = "Name of the Kubernetes connector"
  type        = string
  default     = "chaosk8sconnector"
}

variable "delegate_selectors" {
  description = "Selectors to use for the Kubernetes connector"
  type        = list(string)
  default     = ["chaos-delegate"]
}

// Infrastructure Variables
variable "environment_identifier" {
  description = "Environment identifier"
  type        = string
  default     = "tf_demo_env"
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "terraform demo env"
}

variable "infrastructure_identifier" {
  description = "Infrastructure identifier"
  type        = string
  default     = "tf_demo_infra"
}

variable "deployment_type" {
  description = "Deployment type for the infrastructure"
  type        = string
  default     = "Kubernetes"
}

variable "infrastructure_name" {
  description = "Name of the infrastructure"
  type        = string
  default     = "terraform demo infra"
}

variable "namespace" {
  description = "Kubernetes namespace for the infrastructure"
  type        = string
  default     = "hce"
}

// Registry Variables
variable "setup_custom_registry" {
  description = "Whether to setup custom registry"
  type        = bool
  default     = true
}

variable "registry_username" {
  description = "Username for the container registry"
  type        = string
  default     = ""
  sensitive   = true
}

variable "registry_password" {
  description = "Password for the container registry"
  type        = string
  default     = ""
  sensitive   = true
}

variable "registry_server" {
  description = "URL of the container registry"
  type        = string
  default     = "harness.io"
}

variable "registry_account" {
  description = "Account name for the container registry"
  type        = string
  default     = "harness"
}

variable "registry_secret_name" {
  description = "Name of the Kubernetes secret containing registry credentials"
  type        = string
  default     = ""
}

variable "is_private_registry" {
  description = "Whether the container registry is private"
  type        = bool
  default     = false
}

variable "is_default_registry" {
  description = "Whether this should be the default registry"
  type        = bool
  default     = false
}

variable "is_override_allowed" {
  description = "Whether to allow overriding the registry settings"
  type        = bool
  default     = true
}

variable "use_custom_images" {
  description = "Whether to use custom images for chaos components"
  type        = bool
  default     = true
}

variable "log_watcher_image" {
  description = "Custom image for log watcher"
  type        = string
  default     = "docker.io/harness/chaos-log-watcher:1.72.0"
}

variable "ddcr_image" {
  description = "Custom image for DDCR (Dedicated Data Collection and Reporting)"
  type        = string
  default     = "docker.io/harness/chaos-ddcr:1.72.0"
}

variable "ddcr_lib_image" {
  description = "Custom image for DDCR library"
  type        = string
  default     = "docker.io/harness/chaos-ddcr-faults:1.72.0"
}

variable "ddcr_fault_image" {
  description = "Custom image for DDCR fault injection"
  type        = string
  default     = "docker.io/harness/chaos-ddcr-faults:1.72.0"
}

// Chaos Infrastructure Configuration
variable "chaos_infrastructure_identifier" {
  description = "Identifier for the chaos infrastructure"
  type        = string
  default     = "chaos_terraform_infra"
}

variable "chaos_infra_name" {
  description = "Name of the chaos infrastructure"
  type        = string
  default     = "chaos terraform infra"
}

variable "chaos_infra_description" {
  description = "Description for the chaos infrastructure"
  type        = string
  default     = "Chaos Infrastructure for running chaos experiments"
}

variable "chaos_infra_namespace" {
  description = "Kubernetes namespace for the chaos infrastructure"
  type        = string
  default     = "hce"
}

variable "chaos_infra_type" {
  description = "Type of the chaos infrastructure"
  type        = string
  default     = "KUBERNETESV2"
}

variable "chaos_run_as_user" {
  description = "User ID to run the chaos infrastructure pods as"
  type        = number
  default     = null
}

variable "chaos_run_as_group" {
  description = "Group ID to run the chaos infrastructure pods as"
  type        = number
  default     = null
}

variable "chaos_ai_enabled" {
  description = "Whether AI features are enabled for the chaos infrastructure"
  type        = bool
  default     = false
}

variable "chaos_insecure_skip_verify" {
  description = "Whether to skip TLS verification for the chaos infrastructure"
  type        = bool
  default     = false
}

variable "node_selector" {
  description = "Node selector for the chaos infrastructure pods"
  type        = map(string)
  default     = {}
}

variable "chaos_labels" {
  description = "Labels to apply to the chaos infrastructure"
  type        = map(string)
  default     = {}
}

variable "chaos_annotations" {
  description = "Annotations to apply to the chaos infrastructure"
  type        = map(string)
  default     = {}
}

variable "chaos_volumes" {
  description = "Volumes to mount in the chaos infrastructure pods"
  type = list(object({
    name       = string
    size_limit = string
  }))
  default = []
}

variable "chaos_volume_mounts" {
  description = "Volume mounts for the chaos infrastructure pods"
  type = list(object({
    name             = string
    mount_path       = string
    read_only        = bool
    mount_propagation = string
  }))
  default = []
}

variable "chaos_env_vars" {
  description = "Environment variables for the chaos infrastructure"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "chaos_tolerations" {
  description = "Tolerations for the chaos infrastructure pods"
  type = list(object({
    key                = string
    operator           = string
    value              = string
    effect             = string
    toleration_seconds = number
  }))
  default = []
}

variable "chaos_mtls" {
  description = "mTLS configuration for the chaos infrastructure"
  type = object({
    cert_path   = string
    key_path    = string
    secret_name = string
    url         = string
  })
  default = null
}

variable "chaos_proxy" {
  description = "Proxy configuration for the chaos infrastructure"
  type = object({
    http_proxy  = string
    https_proxy = string
    no_proxy    = string
    url         = string
  })
  default = null
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account for chaos infrastructure"
  type        = string
  default     = "litmus"
}

// Service Discovery Agent Variables
variable "service_discovery_agent_name" {
  description = "Name of the service discovery agent"
  type        = string
  default     = "service discovery terraform agent"
}

variable "sd_installation_type" {
  description = "Type of installation for the service discovery agent"
  type        = string
  default     = "CONNECTOR"  # or "MANIFEST" depending on your needs
  
  validation {
    condition     = contains(["CONNECTOR", "MANIFEST"], var.sd_installation_type)
    error_message = "Installation type must be either 'CONNECTOR' or 'MANIFEST'"
  }
}

variable "permanent_installation" {
  description = "Whether the service discovery agent is permanently installed"
  type        = bool
  default     = false
}

variable "correlation_id" {
  description = "Correlation ID for the service discovery agent"
  type        = string
  default     = null
}

variable "sd_collector_image" {
  description = "Docker image for the service discovery collector"
  type        = string
  default     = "harness/service-discovery-collector:main-latest"
}

variable "sd_log_watcher_image" {
  description = "Docker image for the log watcher"
  type        = string
  default     = "harness/chaos-log-watcher:main-latest"
}

variable "skip_secure_verify" {
  description = "Whether to skip TLS verification"
  type        = bool
  default     = false
}

variable "sd_namespace" {
  description = "Kubernetes namespace for the service discovery agent"
  type        = string
  default     = "tf-discovery"
}

variable "sd_service_account" {
  description = "Service account for the service discovery agent"
  type        = string
  default     = "tf-discovery-sa"
}

variable "sd_image_pull_policy" {
  description = "Image pull policy for the service discovery agent"
  type        = string
  default     = "Always"
}

variable "sd_run_as_user" {
  description = "User ID to run the service discovery agent as"
  type        = number
  default     = 2000
}

variable "sd_run_as_group" {
  description = "Group ID to run the service discovery agent as"
  type        = number
  default     = 2000
}

variable "sd_kubernetes_labels" {
  description = "Labels to apply to the service discovery agent pods"
  type        = map(string)
  default     = {}
}

variable "sd_kubernetes_annotations" {
  description = "Annotations to apply to the service discovery agent pods"
  type        = map(string)
  default     = {}
}

variable "sd_node_selector" {
  description = "Node selector for the service discovery agent pods"
  type        = map(string)
  default     = {}
}

variable "sd_resources_limits" {
  description = "Resource limits for the service discovery agent"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "500m"
    memory = "512Mi"
  }
}

variable "sd_resources_requests" {
  description = "Resource requests for the service discovery agent"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "250m"
    memory = "256Mi"
  }
}

variable "sd_tolerations" {
  description = "Tolerations for the service discovery agent pods"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "enable_node_agent" {
  description = "Whether to enable node agent for service discovery"
  type        = bool
  default     = true
}

variable "node_agent_selector" {
  description = "Node selector for the node agent"
  type        = string
  default     = ""
}

variable "enable_batch_resources" {
  description = "Whether to enable batch resources collection"
  type        = bool
  default     = false
}

variable "enable_orphaned_pod" {
  description = "Whether to enable orphaned pod detection"
  type        = bool
  default     = false
}

variable "namespace_selector" {
  description = "Label selector for namespaces to watch"
  type        = string
  default     = ""
}

variable "collection_window_in_min" {
  description = "Collection window in minutes"
  type        = number
  default     = 5
}

variable "blacklisted_namespaces" {
  description = "List of namespaces to exclude from discovery"
  type        = list(string)
  default     = ["kube-system", "kube-public"]
}

variable "observed_namespaces" {
  description = "List of namespaces to observe (if empty, all namespaces are observed)"
  type        = list(string)
  default     = []
}

variable "sd_cron_expression" {
  description = "Cron expression for the service discovery schedule"
  type        = string
  default     = "0/15 * * * *"
}


// Git Connector Variables
variable "create_git_connector" {
  description = "Whether to create a Git connector"
  type        = bool
  default     = false
}



// variable "git_connector_url" {
//   description = "URL of the Git repository"
//   type        = string
//   default     = ""
// }

// variable "git_connector_username" {
//   description = "Username for Git authentication"
//   type        = string
//   default     = ""
//   sensitive   = true
// }

// variable "git_connector_password" {
//   description = "Password or token for Git authentication"
//   type        = string
//   default     = ""
//   sensitive   = true
// }

// variable "git_connector_ssh_key" {
//   description = "SSH private key for Git authentication"
//   type        = string
//   default     = ""
//   sensitive   = true
// }

// variable "git_connector_ssh_key_passphrase" {
//   description = "Passphrase for the SSH private key"
//   type        = string
//   default     = ""
//   sensitive   = true
// }

variable "git_connector_validation_repo" {
  description = "Repository to validate the Git connector"
  type        = string
  default     = ""
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
  default     = ""
}

variable "github_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
  default     = ""
}

variable "github_private_key_ref" {
  description = "Reference to the GitHub App private key"
  type        = string
  default     = ""
}

variable "git_connector_name" {
  description = "Name for the Git connector (only used if create_git_connector is true)"
  type        = string
  default     = "harness-chaos-hub-git-connector"
}

variable "git_connector_url" {
  description = "URL for the Git repository (only used if create_git_connector is true)"
  type        = string
  default     = "https://github.com/wings-software/enterprise-chaos-hub"
}

variable "git_connector_branch" {
  description = "Branch for the Git repository (only used if create_git_connector is true)"
  type        = string
  default     = "main"
}

variable "git_connector_username" {
  description = "Username for Git authentication (only used if create_git_connector is true and using username/password auth)"
  type        = string
  default     = "sagarkrsd"
  sensitive   = true
}

variable "git_connector_password" {
  description = "Password or token for Git authentication (only used if create_git_connector is true and using username/password auth)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_connector_ssh_key" {
  description = "SSH private key for Git authentication (only used if create_git_connector is true and using SSH auth)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_connector_ssh_key_passphrase" {
  description = "Passphrase for SSH private key (only used if create_git_connector is true and using SSH auth with passphrase)"
  type        = string
  default     = ""
  sensitive   = true
}

// Chaos Hub Variables
variable "create_chaos_hub" {
  description = "Whether to create a Chaos Hub"
  type        = bool
  default     = true
}

variable "create_chaos_hub_v2_account_level" {
  description = "Whether to create a Chaos Hub V2 Account Level"
  type        = bool
  default     = true
}

variable "create_chaos_hub_v2_org_level" {
  description = "Whether to create a Chaos Hub V2 Org Level"
  type        = bool
  default     = true
}

variable "create_chaos_hub_v2_project_level" {
  description = "Whether to create a Chaos Hub V2 Project Level"
  type        = bool
  default     = true
}

variable "chaos_hub_name" {
  description = "Name of the Chaos Hub"
  type        = string
  default     = "harness-chaos-hub"
}

variable "chaos_hub_v2_account_level_name" {
  description = "Name of the Chaos Hub"
  type        = string
  default     = "tf-chaos-hub-account-level"
}

variable "chaos_hub_v2_account_level_identity" {
  description = "Identity of the Chaos Hub"
  type        = string
  default     = "tf-chaos-hub-account-level"
}

variable "chaos_hub_v2_org_level_name" {
  description = "Name of the Chaos Hub"
  type        = string
  default     = "tf-chaos-hub-org-level"
}

variable "chaos_hub_v2_org_level_identity" {
  description = "Identity of the Chaos Hub"
  type        = string
  default     = "tf-chaos-hub-org-level"
}

variable "chaos_hub_v2_project_level_name" {
  description = "Name of the Chaos Hub"
  type        = string
  default     = "tf-chaos-hub-project-level"
}

variable "chaos_hub_v2_project_level_identity" {
  description = "Identity of the Chaos Hub"
  type        = string
  default     = "tf-chaos-hub-project-level"
}

variable "chaos_hub_description" {
  description = "Description of the Chaos Hub"
  type        = string
  default     = "Harness Chaos Hub for chaos experiments"
}

variable "chaos_hub_connector_id" {
  description = "ID of the Git connector for the Chaos Hub"
  type        = string
  default     = "tfchaoshubacclevelconnector"
}

variable "chaos_hub_connector_scope" {
  description = "Scope of the Git connector for the Chaos Hub"
  type        = string
  default     = "PROJECT"
}

variable "chaos_hub_repo_branch" {
  description = "Branch for the Chaos Hub repository"
  type        = string
  default     = "main"
}

variable "chaos_hub_repo_name" {
  description = "Name of the Chaos Hub repository"
  type        = string
  default     = "enterprise-chaos-hub"
}

variable "chaos_hub_is_default" {
  description = "Whether this should be the default Chaos Hub"
  type        = bool
  default     = false
}

variable "chaos_hub_tags" {
  description = "Tags to apply to the Chaos Hub"
  type        = list(string)
  default     = ["harness", "chaos-engineering"]
}

# Security Governance Condition Variables
variable "security_governance_condition_name" {
  description = "Name of the security governance condition"
  type        = string
  default     = "deny-destructive-experiments"
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
  description = "Operator for the fault specification (EQUAL_TO, NOT_EQUAL_TO, etc.)"
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
      name       = "pod-delete"
    },
    {
      fault_type = "FAULT"
      name       = "container-kill"
    }
  ]
}

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
        label              = "app=boutique"
        services           = ["boutique"]
        application_map_id = "boutique-app"
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
    service_accounts = ["default"]
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
    duration   = string
    recurrence = object({
      type  = string
      until = number
    })
  }))
  default = [
    {
      time_zone  = "UTC"
      start_time = 1711238400000  # Default start time (March 23, 2024 00:00:00 UTC)
      duration   = "24h"
      recurrence = {
        type  = "Daily"
        until = -1  # Recur indefinitely
      }
    }
  ]
}

# Common Variables
variable "annotations" {
  description = "Annotations to apply to resources"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "chaos_service_account" {
  description = "Service account for chaos infrastructure"
  type        = string
  default     = "chaos-service-account"
}

# Common Tags
variable "tags" {
  description = "Common tags for all resources as a map of strings"
  type        = map(string)
  default     = {
    "managed_by" = "terraform"
    "purpose"    = "chaos-engineering"
  }
}

