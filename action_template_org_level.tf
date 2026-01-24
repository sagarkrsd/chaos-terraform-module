# Container Action Template - ORG LEVEL
# ============================================================================
# Purpose: Comprehensive container action with all volume types
# Scope: org_id only, no project_id
# ============================================================================

resource "harness_chaos_action_template" "container_complex_volumes_org" {
  depends_on = [
    harness_chaos_hub_v2.org_level
  ]

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity    = "container-complex-volumes-org"
  name        = "Container Action - Complex Volumes Org"
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

  tags = ["terraform", "container", "volumes", "complex", "org"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Output
output "action_template_org_id" {
  description = "ID of action template (org level)"
  value       = harness_chaos_action_template.container_complex_volumes_org.id
}

output "action_template_org_identity" {
  description = "Identity of action template (org level)"
  value       = harness_chaos_action_template.container_complex_volumes_org.identity
}
