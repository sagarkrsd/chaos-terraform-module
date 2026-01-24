# ============================================================================
# Multi-Scope Tests for ALL Template Types
# ============================================================================
# Purpose: Test fault, action, probe, and experiment templates at all scopes
# Scopes: Account, Org, Project
# ============================================================================

# ============================================================================
# FAULT TEMPLATES - Multi-Scope
# ============================================================================

# ----------------------------------------------------------------------------
# Fault Template - Account Level
# ----------------------------------------------------------------------------
resource "harness_chaos_fault_template" "account_level" {
  count = 0 # Disabled - using custom_fault_template_account_level.tf instead

  # Account level - no org_id or project_id
  hub_identity = harness_chaos_hub_v2.account_level[0].identity

  identity = "custom-fault-template-account"
  name     = "custom-fault-template-account"
  
  category            = ["Kubernetes"]
  infrastructures     = ["KubernetesV2"]
  type                = "Custom"
  permissions_required = "Basic"

  links {
    name = "Permissions"
    url  = ""
  }

  spec {
    chaos {
      fault_name = "byoc-injector"

      params {
        name  = "CHAOS_DURATION"
        value = "30s"
      }
      params {
        name  = "CHAOS_INTERVAL"
        value = "30"
      }
      params {
        name  = "PARAM1"
        value = "VALUE1"
      }
      params {
        name  = "PARAM2"
        value = "VALUE2"
      }

      kubernetes {
        image             = "harness/custom-chaos:ci"
        command           = ["cmd1", "cmd2", "cmd3"]
        args              = ["arg1", "arg2", "arg3"]
        image_pull_policy = "IfNotPresent"
        image_pull_secrets = ["image secret 1", "image secret 2", "image secret 3"]

        labels = {
          label1 = "val1"
          label2 = "val1"
        }

        annotations = {
          ann1 = "val1"
          ann2 = "val2"
        }

        node_selector = {
          ns1 = "ns2"
          ns2 = "343"
        }

        host_network = true
        host_pid     = true
        host_ipc     = true

        env {
          name  = "env1"
          value = "val1"
        }
        env {
          name  = "env2"
          value = "env3"
        }

        pod_security_context {
          run_as_user  = 222
          run_as_group = 333
          fs_group     = 220
        }

        container_security_context {
          capabilities {
            add  = ["NET_ADMIN", "SYS_ADMIN"]
            drop = ["NET_ADMIN", "SYS_ADMIN"]
          }
          privileged                   = true
          read_only_root_filesystem    = true
          allow_privilege_escalation   = true
        }

        config_maps {
          name       = "cm3"
          mount_path = "mp3"
          mount_mode = 1
        }
        config_maps {
          name       = "cm2"
          mount_path = "mp4"
          mount_mode = 1
        }

        secrets {
          secret_name = "secret1"
          mount_path  = "mp1"
          mount_mode  = 1
        }
        secrets {
          secret_name = "secret2"
          mount_path  = "mp3"
          mount_mode  = 3
        }

        host_file_volumes {
          name       = "hp1"
          mount_path = "mp1"
          host_path  = "hpp1"
          type       = "BlockDevice"
        }
        host_file_volumes {
          name       = "hp2"
          mount_path = "mp2"
          host_path  = "hpp2"
          type       = "CharDevice"
        }

        resources {
          limits = {
            cpu    = "500m"
            memory = "500Mi"
          }
        }
      }
    }
  }

  depends_on = [harness_chaos_hub_v2.account_level]
}

# ----------------------------------------------------------------------------
# Fault Template - Org Level (IDENTICAL to Account Level)
# ----------------------------------------------------------------------------
resource "harness_chaos_fault_template" "org_level" {
  count = 0 # Disabled - using custom_fault_template_org_level.tf instead

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity = "custom-fault-template-org"
  name     = "custom-fault-template-org"
  
  category            = ["Kubernetes"]
  infrastructures     = ["KubernetesV2"]
  type                = "Custom"
  permissions_required = "Basic"

  links {
    name = "Permissions"
    url  = ""
  }

  spec {
    chaos {
      fault_name = "byoc-injector"

      params {
        name  = "CHAOS_DURATION"
        value = "30s"
      }
      params {
        name  = "CHAOS_INTERVAL"
        value = "30"
      }
      params {
        name  = "PARAM1"
        value = "VALUE1"
      }
      params {
        name  = "PARAM2"
        value = "VALUE2"
      }

      kubernetes {
        image             = "harness/custom-chaos:ci"
        command           = ["cmd1", "cmd2", "cmd3"]
        args              = ["arg1", "arg2", "arg3"]
        image_pull_policy = "IfNotPresent"
        image_pull_secrets = ["image secret 1", "image secret 2", "image secret 3"]

        labels = {
          label1 = "val1"
          label2 = "val1"
        }

        annotations = {
          ann1 = "val1"
          ann2 = "val2"
        }

        node_selector = {
          ns1 = "ns2"
          ns2 = "343"
        }

        host_network = true
        host_pid     = true
        host_ipc     = true

        env {
          name  = "env1"
          value = "val1"
        }
        env {
          name  = "env2"
          value = "env3"
        }

        pod_security_context {
          run_as_user  = 222
          run_as_group = 333
          fs_group     = 220
        }

        container_security_context {
          capabilities {
            add  = ["NET_ADMIN", "SYS_ADMIN"]
            drop = ["NET_ADMIN", "SYS_ADMIN"]
          }
          privileged                   = true
          read_only_root_filesystem    = true
          allow_privilege_escalation   = true
        }

        config_maps {
          name       = "cm3"
          mount_path = "mp3"
          mount_mode = 1
        }
        config_maps {
          name       = "cm2"
          mount_path = "mp4"
          mount_mode = 1
        }

        secrets {
          secret_name = "secret1"
          mount_path  = "mp1"
          mount_mode  = 1
        }
        secrets {
          secret_name = "secret2"
          mount_path  = "mp3"
          mount_mode  = 3
        }

        host_file_volumes {
          name       = "hp1"
          mount_path = "mp1"
          host_path  = "hpp1"
          type       = "BlockDevice"
        }
        host_file_volumes {
          name       = "hp2"
          mount_path = "mp2"
          host_path  = "hpp2"
          type       = "CharDevice"
        }

        resources {
          limits = {
            cpu    = "500m"
            memory = "500Mi"
          }
        }
      }
    }
  }

  depends_on = [harness_chaos_hub_v2.org_level]
}

# ----------------------------------------------------------------------------
# Fault Template - Project Level
# ----------------------------------------------------------------------------
resource "harness_chaos_fault_template" "project_level" {
  count = 1 # Enable to test

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "fault-project-level"
  name     = "fault-project-level"

  category            = ["Kubernetes"]
  infrastructures     = ["KubernetesV2"]
  type                = "Custom"
  permissions_required = "Basic"

  spec {
    chaos {
      fault_name = "byoc-injector"

      params {
        name  = "TOTAL_CHAOS_DURATION"
        value = "30"
      }

      kubernetes {
        image             = "harness/chaos-go-runner:latest"
        command           = ["./experiments", "-name=byoc-injector"]
        image_pull_policy = "IfNotPresent"

        env {
          name  = "TOTAL_CHAOS_DURATION"
          value = "{{ .TOTAL_CHAOS_DURATION }}"
        }
      }
    }
  }

  depends_on = [harness_chaos_hub_v2.project_level]
}

# ============================================================================
# ACTION TEMPLATES - Multi-Scope
# ============================================================================

# ----------------------------------------------------------------------------
# Action Template - Account Level (Comprehensive Container with All Volumes)
# ----------------------------------------------------------------------------
resource "harness_chaos_action_template" "account_level" {
  count = 0 # Disabled - using action_template_account_level.tf instead

  # Account level - no org_id or project_id
  hub_identity = harness_chaos_hub_v2.account_level[0].identity

  identity    = "container-complex-volumes-account"
  name        = "Container Action - Complex Volumes Account"
  description = "Container action with all volume types and runtime inputs"
  type        = "container"

  infrastructure_type = "<+input>"

  container_action {
    image     = "<+input>"
    command   = ["<+input>"]
    args      = "<+input>"
    namespace = "<+input>"

    # EmptyDir volume
    volumes {
      name = "cache-volume"
      empty_dir {
        medium = "Memory"
      }
    }

    # ConfigMap volume
    volumes {
      name = "config-volume"
      config_map {
        name     = "<+input>"
        optional = false
      }
    }

    # Secret volume
    volumes {
      name = "secret-volume"
      secret {
        secret_name = "<+input>"
        optional    = false
      }
    }

    # HostPath volume
    volumes {
      name = "host-volume"
      host_path {
        path = "<+input>"
        type = "Directory"
      }
    }

    # PVC volume
    volumes {
      name = "pvc-volume"
      persistent_volume_claim {
        claim_name = "<+input>"
        read_only  = false
      }
    }

    # Volume mounts
    volume_mounts {
      name       = "cache-volume"
      mount_path = "/cache"
      read_only  = false
    }

    volume_mounts {
      name       = "config-volume"
      mount_path = "/config"
      sub_path   = "app.conf"
      read_only  = true
    }

    volume_mounts {
      name       = "secret-volume"
      mount_path = "/secrets"
      read_only  = true
    }

    volume_mounts {
      name       = "host-volume"
      mount_path = "/host-data"
      read_only  = false
    }

    volume_mounts {
      name       = "pvc-volume"
      mount_path = "/data"
      read_only  = false
    }
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "15s"
    initial_delay   = "10s"
    stop_on_failure = false
    verbosity       = "info"
    max_retries     = 7
  }

  variables {
    name        = "configmap_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "ConfigMap name"
  }

  variables {
    name        = "secret_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Secret name"
  }

  variables {
    name        = "host_path"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Host path"
  }

  variables {
    name        = "pvc_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "PVC name"
  }

  tags = ["terraform", "container", "volumes", "complex", "account"]

  depends_on = [harness_chaos_hub_v2.account_level]
}

# ----------------------------------------------------------------------------
# Action Template - Org Level
# ----------------------------------------------------------------------------
resource "harness_chaos_action_template" "org_level" {
  count = 0 # Disabled - using action_template_org_level.tf instead

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity    = "action-org-level"
  name        = "action-org-level"
  description = "Org level delay action"
  type        = "delay"

  infrastructure_type = "Kubernetes"

  delay_action {
    duration = "30s"
  }

  run_properties {
    timeout  = "60s"
    interval = "10s"
  }

  depends_on = [harness_chaos_hub_v2.org_level]
}

# ----------------------------------------------------------------------------
# Action Template - Project Level
# ----------------------------------------------------------------------------
resource "harness_chaos_action_template" "project_level" {
  count = 1 # Enable to test

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity    = "action-project-level"
  name        = "action-project-level"
  description = "Project level delay action"
  type        = "delay"

  infrastructure_type = "Kubernetes"

  delay_action {
    duration = "30s"
  }

  run_properties {
    timeout  = "60s"
    interval = "10s"
  }

  depends_on = [harness_chaos_hub_v2.project_level]
}

# ============================================================================
# PROBE TEMPLATES - Multi-Scope
# ============================================================================

# ----------------------------------------------------------------------------
# Probe Template - Account Level
# ----------------------------------------------------------------------------
resource "harness_chaos_probe_template" "account_level" {
  count = 1 # Enable to test

  # Account level - no org_id or project_id
  hub_identity = harness_chaos_hub_v2.account_level[0].identity

  identity    = "probe-account-level"
  name        = "probe-account-level"
  description = "Account level HTTP probe"
  type        = "httpProbe"

  infrastructure_type = "Kubernetes"

  http_probe {
    url = "https://example.com/health"

    method {
      get {
        criteria      = "=="
        response_code = "200"
      }
    }
  }

  run_properties {
    timeout  = "30s"
    interval = "5s"
  }

  depends_on = [harness_chaos_hub_v2.account_level]
}

# ----------------------------------------------------------------------------
# Probe Template - Org Level
# ----------------------------------------------------------------------------
resource "harness_chaos_probe_template" "org_level" {
  count = 1 # Enable to test

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity    = "probe-org-level"
  name        = "probe-org-level"
  description = "Org level HTTP probe"
  type        = "httpProbe"

  infrastructure_type = "Kubernetes"

  http_probe {
    url = "https://example.com/health"

    method {
      get {
        criteria      = "=="
        response_code = "200"
      }
    }
  }

  run_properties {
    timeout  = "30s"
    interval = "5s"
  }

  depends_on = [harness_chaos_hub_v2.org_level]
}

# ----------------------------------------------------------------------------
# Probe Template - Project Level
# ----------------------------------------------------------------------------
resource "harness_chaos_probe_template" "project_level" {
  count = 1 # Enable to test

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity    = "probe-project-level"
  name        = "probe-project-level"
  description = "Project level HTTP probe"
  type        = "httpProbe"

  infrastructure_type = "Kubernetes"

  http_probe {
    url = "https://example.com/health"

    method {
      get {
        criteria      = "=="
        response_code = "200"
      }
    }
  }

  run_properties {
    timeout  = "30s"
    interval = "5s"
  }

  depends_on = [harness_chaos_hub_v2.project_level]
}

# ============================================================================
# EXPERIMENT TEMPLATES - Multi-Scope
# ============================================================================

# ----------------------------------------------------------------------------
# Experiment Template - Account Level
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "account_level" {
  count = 1 # Enable to test

  # Account level - no org_id or project_id
  hub_identity = harness_chaos_hub_v2.account_level[0].identity

  identity = "exp-account-level"
  name     = "exp-account-level"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.account_level
  ]

  spec {
    infra_type = "KubernetesV2"

    faults {
      identity      = "pod-delete"
      name          = "pod-delete-acc"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = false

      values {
        name  = "TARGET_WORKLOAD_KIND"
        value = "deployment"
      }
      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
    }

    vertices {
      name = "v-start"
      start {
        faults {
          name = "pod-delete-acc"
        }
      }
      end {}
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "pod-delete-acc"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Experiment Template - Org Level
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "org_level" {
  count = 1 # Enable to test

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity = "exp-org-level"
  name     = "exp-org-level"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.org_level
  ]

  spec {
    infra_type = "KubernetesV2"

    faults {
      identity      = "pod-network-loss"
      name          = "pod-network-loss-org"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = false

      values {
        name  = "TARGET_WORKLOAD_KIND"
        value = "deployment"
      }
      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
    }

    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-org"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
    }

    vertices {
      name = "v-start"
      start {
        faults {
          name = "pod-network-loss-org"
        }
        probes {
          name = "pod-replica-count-check-org"
        }
      }
      end {}
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "pod-network-loss-org"
        }
        probes {
          name = "pod-replica-count-check-org"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Experiment Template - Project Level
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "project_level" {
  count = 1 # Enable to test

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "exp-project-level"
  name     = "exp-project-level"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level
  ]

  spec {
    infra_type = "KubernetesV2"

    faults {
      identity      = "container-kill"
      name          = "container-kill-proj"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = false

      values {
        name  = "TARGET_WORKLOAD_KIND"
        value = "deployment"
      }
      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
    }

    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-proj"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
    }

    vertices {
      name = "v-start"
      start {
        faults {
          name = "container-kill-proj"
        }
        probes {
          name = "pod-replica-count-check-proj"
        }
      }
      end {}
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "container-kill-proj"
        }
        probes {
          name = "pod-replica-count-check-proj"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ============================================================================
# Outputs
# ============================================================================
# Note: Outputs moved to individual template files:
# - custom_fault_template_account_level.tf
# - custom_fault_template_org_level.tf
# - action_template_account_level.tf
# - action_template_org_level.tf
# - probe_template_account_level.tf
# - probe_template_org_level.tf

# Experiment Template Outputs (still in this file)
output "experiment_template_account_id" {
  value = length(harness_chaos_experiment_template.account_level) > 0 ? harness_chaos_experiment_template.account_level[0].id : null
}

output "experiment_template_org_id" {
  value = length(harness_chaos_experiment_template.org_level) > 0 ? harness_chaos_experiment_template.org_level[0].id : null
}

output "experiment_template_project_id" {
  value = length(harness_chaos_experiment_template.project_level) > 0 ? harness_chaos_experiment_template.project_level[0].id : null
}
