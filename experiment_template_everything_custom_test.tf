# ============================================================================
# Experiment Template Test - Everything Custom + Enterprise
# ============================================================================
# Purpose: Ultimate test with custom faults, actions, probes + enterprise templates
# Based on the YAML example: everythingcustomdefinedexp
# ============================================================================

# ----------------------------------------------------------------------------
# Test 11: Everything Custom - Custom + Enterprise Mix
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "everything_custom" {
  count = 1 # Enable for testing

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "everythingcustomdefinedexp"
  name     = "everything-custom-defined-exp"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level,
    harness_chaos_fault_template.custom
  ]

  spec {
    infra_type = "KubernetesV2"

    # Enterprise Actions (using grafana and datadog from enterprise hub)
    actions {
      identity               = "grafana-chaos-annotation"
      name                   = "grafana-chaos-annotation-z47-z47"
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
        name  = "DASHBOARD_UID"
        value = "<+input>"
      }
      values {
        name  = "MODE"
        value = "<+input>"
      }
    }

    actions {
      identity               = "datadog-chaos-event"
      name                   = "datadog-chaos-event-b4a-b4a"
      is_enterprise          = true
      continue_on_completion = false

      values {
        name  = "DATADOG_URL"
        value = "<+input>"
      }
      values {
        name  = "DATADOG_API_KEY"
        value = "<+input>"
      }
      values {
        name  = "MODE"
        value = "start"
      }
    }

    # Custom Fault + Enterprise Fault
    faults {
      identity      = harness_chaos_fault_template.custom.identity
      name          = "custom-fault-template-i4c"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
      # Empty values array
    }

    faults {
      identity      = "node-cpu-hog"
      name          = "node-cpu-hog-lnn"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = false

      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
      values {
        name  = "SEQUENCE"
        value = "<+input>"
      }
      values {
        name  = "NODE_CPU_CORE"
        value = "<+input>"
      }
      values {
        name  = "CPU_LOAD"
        value = "<+input>"
      }
      values {
        name  = "TARGET_NODES"
        value = "<+input>"
      }
      values {
        name  = "NODE_LABEL"
        value = "<+input>"
      }
      values {
        name  = "NODES_AFFECTED_PERCENTAGE"
        value = "100"
      }
    }

    # Enterprise Probes (using existing enterprise hub templates)
    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-p7h-p7h"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
    }

    probes {
      identity      = "container-restart-check"
      name          = "container-restart-check-ibn-ibn"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
    }

    probes {
      identity      = "aws-ec2-instance-status-check"
      name          = "aws-ec2-instance-status-check-vf4-vf4"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "EC2_INSTANCE_ID"
        value = "<+input>"
      }
      values {
        name  = "REGION"
        value = "<+input>"
      }
    }

    probes {
      identity      = "gcp-vm-instance-status-check"
      name          = "gcp-vm-instance-status-check-2ae-2ae"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "VM_INSTANCE_NAMES"
        value = "<+input>"
      }
      values {
        name  = "INSTANCE_LABEL"
        value = "<+input>"
      }
      values {
        name  = "GCP_PROJECT_ID"
        value = "<+input>"
      }
      values {
        name  = "ZONES"
        value = "<+input>"
      }
    }

    # Complex 5-vertex workflow
    vertices {
      name = "v-iel"
      start {
        probes {
          name = "container-restart-check-ibn-ibn"
        }
      }
      end {}
    }

    vertices {
      name = "v-i66"
      start {
        faults {
          name = "custom-fault-template-i4c"
        }
        probes {
          name = "pod-replica-count-check-p7h-p7h"
        }
        actions {
          name = "grafana-chaos-annotation-z47-z47"
        }
      }
      end {
        probes {
          name = "container-restart-check-ibn-ibn"
        }
      }
    }

    vertices {
      name = "v-vht"
      start {
        probes {
          name = "aws-ec2-instance-status-check-vf4-vf4"
        }
        actions {
          name = "datadog-chaos-event-b4a-b4a"
        }
      }
      end {
        faults {
          name = "custom-fault-template-i4c"
        }
        probes {
          name = "pod-replica-count-check-p7h-p7h"
        }
        actions {
          name = "grafana-chaos-annotation-z47-z47"
        }
      }
    }

    vertices {
      name = "v-lpf"
      start {
        faults {
          name = "node-cpu-hog-lnn"
        }
        probes {
          name = "gcp-vm-instance-status-check-2ae-2ae"
        }
      }
      end {
        probes {
          name = "aws-ec2-instance-status-check-vf4-vf4"
        }
        actions {
          name = "datadog-chaos-event-b4a-b4a"
        }
      }
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "node-cpu-hog-lnn"
        }
        probes {
          name = "gcp-vm-instance-status-check-2ae-2ae"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Outputs
output "everything_custom_id" {
  description = "ID of everything custom experiment template"
  value       = length(harness_chaos_experiment_template.everything_custom) > 0 ? harness_chaos_experiment_template.everything_custom[0].id : null
}

output "everything_custom_identity" {
  description = "Identity of everything custom experiment template"
  value       = length(harness_chaos_experiment_template.everything_custom) > 0 ? harness_chaos_experiment_template.everything_custom[0].identity : null
}
