# Comprehensive fault template test
# Based on successful curl request format

resource "harness_chaos_fault_template" "comprehensive" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]
  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "tf-comprehensive-test"
  name        = "TF Comprehensive Test"
  description = "Comprehensive fault template with all kubernetes spec fields"

  # Metadata
  infrastructures      = ["KubernetesV2"]
  category             = ["Kubernetes"]
  type                 = "Custom"
  tags                 = ["terraform", "comprehensive", "test"]
  permissions_required = "Basic"

  # Links (matching curl format)
  links {
    name = "Permissions"
    url  = ""
  }

  # Spec with comprehensive kubernetes configuration
  spec {
    chaos {
      fault_name = "byoc-injector"

      # Multiple parameters
      params {
        name  = "CHAOS_DURATION"
        value = "30s"
      }

      params {
        name  = "CHAOS_INTERVAL"
        value = "10s"
      }

      params {
        name  = "SOME_OTHER_PARAM"
        value = "PARAM_VALUE"
      }

      # Kubernetes spec - using only fields that exist in current schema
      kubernetes {
        image              = "harness/custom:ci"
        image_pull_policy  = "Always"
        image_pull_secrets = ["image-pull-secret1", "image-pull-secret2"]
        host_pid           = true

        # Resource requirements
        resources {
          limits = {
            cpu    = "500m"
            memory = "500Mi"
          }
          requests = {
            cpu    = "250m"
            memory = "250Mi"
          }
        }

        # ConfigMap volumes (schema uses 'config_maps' not 'config_map_volume')
        config_maps {
          name       = "configmap1"
          mount_path = "/config/path1"
        }

        config_maps {
          name       = "configmap2"
          mount_path = "/config/path2"
        }

        # Secret volumes (schema uses 'secrets' not 'secret_volume')
        secrets {
          secret_name = "secret-vol1"
          mount_path  = "/secret/path1"
        }

        secrets {
          secret_name = "secret-vol2"
          mount_path  = "/secret/path2"
        }

        # Host file volumes (schema uses 'host_file_volumes' not 'host_path_volume')
        host_file_volumes {
          name       = "hostpath1"
          mount_path = "/host/path1"
        }

        host_file_volumes {
          name       = "hostpath2"
          mount_path = "/host/path2"
        }
      }
    }
  }

  # Variables (empty for this test, matching curl)
  # variables block is optional
}

output "comprehensive_fault_template_id" {
  value = harness_chaos_fault_template.comprehensive.id
}

output "comprehensive_fault_template_identity" {
  value = harness_chaos_fault_template.comprehensive.identity
}

output "comprehensive_fault_template_name" {
  value = harness_chaos_fault_template.comprehensive.name
}
