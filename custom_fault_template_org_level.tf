# ============================================================================
# Custom Fault Template Test - ORG LEVEL
# ============================================================================
# Purpose: Create a custom fault template at ORG level
# Scope: org_id only, no project_id
# ============================================================================

resource "harness_chaos_fault_template" "custom_org" {
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

  depends_on = [
    harness_chaos_hub_v2.org_level
  ]
}

# Output for reference
output "custom_fault_template_org_id" {
  description = "ID of custom fault template (org level)"
  value       = harness_chaos_fault_template.custom_org.id
}

output "custom_fault_template_org_identity" {
  description = "Identity of custom fault template (org level)"
  value       = harness_chaos_fault_template.custom_org.identity
}
