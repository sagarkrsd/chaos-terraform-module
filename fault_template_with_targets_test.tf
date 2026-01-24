# Fault template test with kubernetes targets
# Tests the target specification

resource "harness_chaos_fault_template" "with_targets" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]
  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "tf-with-targets-test"
  name        = "TF With Targets Test"
  description = "Fault template with kubernetes target specifications"

  infrastructures      = ["KubernetesV2"]
  category             = ["Kubernetes"]
  type                 = "Custom"
  tags                 = ["terraform", "targets", "test"]
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

      kubernetes {
        image = "harness/custom:ci"
      }
    }

    # Target specification
    target {
      # Target 1: Deployment with labels
      kubernetes {
        kind      = "deployment"
        namespace = "default"
        labels = {
          app  = "nginx"
          tier = "frontend"
        }
      }

      # Target 2: StatefulSet with specific names
      kubernetes {
        kind      = "statefulset"
        namespace = "production"
        labels = {
          app = "database"
        }
        names = ["postgres-0", "postgres-1"]
      }

      # Target 3: DaemonSet in kube-system
      kubernetes {
        kind      = "daemonset"
        namespace = "kube-system"
        labels = {
          component = "monitoring"
        }
      }
    }
  }
}

output "with_targets_fault_template_id" {
  value = harness_chaos_fault_template.with_targets.id
}

output "with_targets_fault_template_identity" {
  value = harness_chaos_fault_template.with_targets.identity
}
