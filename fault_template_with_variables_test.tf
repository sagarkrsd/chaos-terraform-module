# Fault template test with variables
# Tests variable support including runtime inputs

resource "harness_chaos_fault_template" "with_variables" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]
  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "tf-with-variables-test"
  name        = "TF With Variables Test"
  description = "Fault template with template variables and runtime inputs"

  infrastructures      = ["KubernetesV2"]
  category             = ["Kubernetes"]
  type                 = "Custom"
  tags                 = ["terraform", "variables", "test"]
  permissions_required = "Basic"

  links {
    name = "Permissions"
    url  = ""
  }

  spec {
    chaos {
      fault_name = "byoc-injector"

      # Use variables in params
      params {
        name  = "CHAOS_DURATION"
        value = "<+variables.chaos_duration>"
      }

      params {
        name  = "TARGET_NAMESPACE"
        value = "<+variables.target_namespace>"
      }

      params {
        name  = "CUSTOM_PARAM"
        value = "<+variables.custom_param>"
      }

      kubernetes {
        image = "harness/custom:ci"
      }
    }

    target {
      kubernetes {
        kind      = "deployment"
        namespace = "<+variables.target_namespace>"
        labels = {
          app = "<+variables.target_app>"
        }
      }
    }
  }

  # Variable definitions
  variables {
    name        = "chaos_duration"
    value       = "30s"
    type        = "string"
    required    = false
    description = "Duration of chaos injection"
  }

  variables {
    name        = "target_namespace"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Namespace of target resources"
  }

  variables {
    name        = "target_app"
    value       = "nginx"
    type        = "string"
    required    = false
    description = "Application label for target selection"
  }

  variables {
    name        = "custom_param"
    value       = "default_value"
    type        = "string"
    required    = false
    description = "Custom parameter for fault"
  }

  variables {
    name        = "enable_debug"
    value       = "false"
    type        = "string"
    required    = false
    description = "Enable debug logging"
  }
}

output "with_variables_fault_template_id" {
  value = harness_chaos_fault_template.with_variables.id
}

output "with_variables_fault_template_identity" {
  value = harness_chaos_fault_template.with_variables.identity
}
