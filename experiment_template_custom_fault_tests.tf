# ============================================================================
# Experiment Template Tests - Custom Fault Template
# ============================================================================
# Purpose: Test experiment templates using custom fault templates
# Based on the YAML examples provided
# ============================================================================

# ----------------------------------------------------------------------------
# Test 9: Simple Custom Fault - Only Custom Fault Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "custom_fault_simple" {
  count = 1 # Enable for testing

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "customexptemplateorglevel"
  name     = "custom-exp-template-org-level"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level,
    harness_chaos_fault_template.custom
  ]

  spec {
    infra_type = "KubernetesV2"

    # Custom fault template
    faults {
      identity      = harness_chaos_fault_template.custom.identity
      name          = "custom-fault-template-4b0"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
      # Empty values array
    }

    # Simple 2-vertex workflow
    vertices {
      name = "v-4cj"
      start {
        faults {
          name = "custom-fault-template-4b0"
        }
      }
      end {}
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "custom-fault-template-4b0"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Test 10: Custom Fault with Action and Probe
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "custom_fault_with_action_probe" {
  count = 1 # Enable for testing

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "customexptemplateorglevel2"
  name     = "custom-exp-template-org-level-2"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level,
    harness_chaos_fault_template.custom
  ]

  spec {
    infra_type = "KubernetesV2"

    # Action from enterprise hub
    actions {
      identity               = "grafana-chaos-annotation"
      name                   = "grafana-chaos-annotation-glj-glj"
      is_enterprise          = true
      continue_on_completion = false

      values {
        name  = "GRAFANA_URL"
        value = "<+input>"
      }
      values {
        name  = "GRAFANA_USERNAME"
        value = "<+input>"
      }
      values {
        name  = "GRAFANA_PASSWORD"
        value = "<+input>"
      }
      values {
        name  = "DASHBOARD_UID"
        value = "<+input>"
      }
    }

    # Custom fault template
    faults {
      identity      = harness_chaos_fault_template.custom.identity
      name          = "custom-fault-template-4b0"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
      # Empty values array
    }

    # Probe from enterprise hub
    probes {
      identity      = "aws-ec2-instance-status-check"
      name          = "aws-ec2-instance-status-check-62o-62o"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "EC2_INSTANCE_ID"
        value = "<+input>"
      }
      values {
        name  = "EC2_INSTANCE_TAG"
        value = "<+input>"
      }
      values {
        name  = "REGION"
        value = "<+input>"
      }
      values {
        name  = "TIMEOUT"
        value = "<+input>"
      }
      values {
        name  = "INTERVAL"
        value = "<+input>"
      }
    }

    # Complex workflow with custom fault
    vertices {
      name = "v-4cj"
      start {
        faults {
          name = "custom-fault-template-4b0"
        }
        probes {
          name = "aws-ec2-instance-status-check-62o-62o"
        }
      }
      end {}
    }

    vertices {
      name = "v-go2"
      start {
        actions {
          name = "grafana-chaos-annotation-glj-glj"
        }
      }
      end {
        faults {
          name = "custom-fault-template-4b0"
        }
        probes {
          name = "aws-ec2-instance-status-check-62o-62o"
        }
      }
    }

    vertices {
      name = "v-end"
      start {}
      end {
        actions {
          name = "grafana-chaos-annotation-glj-glj"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Outputs
output "custom_fault_simple_id" {
  description = "ID of simple custom fault experiment template"
  value       = length(harness_chaos_experiment_template.custom_fault_simple) > 0 ? harness_chaos_experiment_template.custom_fault_simple[0].id : null
}

output "custom_fault_simple_identity" {
  description = "Identity of simple custom fault experiment template"
  value       = length(harness_chaos_experiment_template.custom_fault_simple) > 0 ? harness_chaos_experiment_template.custom_fault_simple[0].identity : null
}

output "custom_fault_with_action_probe_id" {
  description = "ID of custom fault with action/probe experiment template"
  value       = length(harness_chaos_experiment_template.custom_fault_with_action_probe) > 0 ? harness_chaos_experiment_template.custom_fault_with_action_probe[0].id : null
}

output "custom_fault_with_action_probe_identity" {
  description = "Identity of custom fault with action/probe experiment template"
  value       = length(harness_chaos_experiment_template.custom_fault_with_action_probe) > 0 ? harness_chaos_experiment_template.custom_fault_with_action_probe[0].identity : null
}
