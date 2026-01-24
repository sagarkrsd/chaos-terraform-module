# ============================================================================
# Experiment Template Tests - Complex Multi-Component Workflows
# ============================================================================
# Purpose: Test complex experiment templates with multiple faults, probes, and actions
# Using enterprise hub templates
# ============================================================================

# ----------------------------------------------------------------------------
# Test 4: Advanced - 1 Fault + 2 Probes + 1 Action
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "with_action" {
  count = 1 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-with-action"
  name     = "tf-with-action"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level
  ]

  spec {
    infra_type = "KubernetesV2"

    # Action from enterprise hub
    actions {
      identity               = "grafana-chaos-annotation"
      name                   = "grafana-chaos-annotation-c3z-c3z"
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
      values {
        name  = "ADDITIONAL_TAGS"
        value = "abc:tag"
      }
    }

    # Fault
    faults {
      identity      = "pod-network-loss"
      name          = "pod-network-loss-dhy"
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

    # Probes
    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-dxo-dxo"
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
      name          = "container-restart-check-w8u-w8u"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
    }

    # Workflow vertices
    vertices {
      name = "v-c5m"
      start {
        actions {
          name = "grafana-chaos-annotation-c3z-c3z"
        }
      }
      end {}
    }

    vertices {
      name = "v-wam"
      start {
        probes {
          name = "container-restart-check-w8u-w8u"
        }
      }
      end {
        actions {
          name = "grafana-chaos-annotation-c3z-c3z"
        }
      }
    }

    vertices {
      name = "v-djj"
      start {
        faults {
          name = "pod-network-loss-dhy"
        }
        probes {
          name = "pod-replica-count-check-dxo-dxo"
        }
      }
      end {
        probes {
          name = "container-restart-check-w8u-w8u"
        }
      }
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "pod-network-loss-dhy"
        }
        probes {
          name = "pod-replica-count-check-dxo-dxo"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Test 5: Advanced - 2 Actions + 1 Fault + 2 Probes
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "two_actions" {
  count = 1 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-two-actions"
  name     = "tf-two-actions"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level
  ]

  spec {
    infra_type = "KubernetesV2"

    # Action 1: Grafana
    actions {
      identity               = "grafana-chaos-annotation"
      name                   = "grafana-chaos-annotation-c3z-c3z"
      is_enterprise          = true
      continue_on_completion = false

      values {
        name  = "GRAFANA_URL"
        value = "<+input>"
      }
      values {
        name  = "MODE"
        value = "<+input>"
      }
    }

    # Action 2: Datadog
    actions {
      identity               = "datadog-chaos-event"
      name                   = "datadog-chaos-event-z1y-z1y"
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
      values {
        name  = "INTERVAL"
        value = "1s"
      }
      values {
        name  = "MAX_RETRIES"
        value = "1"
      }
    }

    # Fault
    faults {
      identity      = "pod-network-loss"
      name          = "pod-network-loss-dhy"
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

    # Probes
    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-dxo-dxo"
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
      name          = "container-restart-check-w8u-w8u"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
    }

    # Complex workflow
    vertices {
      name = "v-c5m"
      start {
        actions {
          name = "grafana-chaos-annotation-c3z-c3z"
        }
      }
      end {}
    }

    vertices {
      name = "v-wam"
      start {
        probes {
          name = "container-restart-check-w8u-w8u"
        }
      }
      end {
        actions {
          name = "grafana-chaos-annotation-c3z-c3z"
        }
      }
    }

    vertices {
      name = "v-djj"
      start {
        faults {
          name = "pod-network-loss-dhy"
        }
        probes {
          name = "pod-replica-count-check-dxo-dxo"
        }
      }
      end {
        probes {
          name = "container-restart-check-w8u-w8u"
        }
      }
    }

    vertices {
      name = "v-z3g"
      start {
        actions {
          name = "datadog-chaos-event-z1y-z1y"
        }
      }
      end {
        faults {
          name = "pod-network-loss-dhy"
        }
        probes {
          name = "pod-replica-count-check-dxo-dxo"
        }
      }
    }

    vertices {
      name = "v-end"
      start {}
      end {
        actions {
          name = "datadog-chaos-event-z1y-z1y"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Test 6: Complex - 2 Faults + 2 Actions + 2 Probes
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "multi_fault" {
  count = 1 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-multi-fault"
  name     = "tf-multi-fault"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level
  ]

  spec {
    infra_type = "KubernetesV2"

    # Actions
    actions {
      identity               = "grafana-chaos-annotation"
      name                   = "grafana-chaos-annotation-c3z-c3z"
      is_enterprise          = true
      continue_on_completion = false

      values {
        name  = "GRAFANA_URL"
        value = "<+input>"
      }
    }

    actions {
      identity               = "datadog-chaos-event"
      name                   = "datadog-chaos-event-z1y-z1y"
      is_enterprise          = true
      continue_on_completion = false

      values {
        name  = "DATADOG_URL"
        value = "<+input>"
      }
      values {
        name  = "MODE"
        value = "start"
      }
    }

    # Fault 1: Pod network loss
    faults {
      identity      = "pod-network-loss"
      name          = "pod-network-loss-dhy"
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
      values {
        name  = "POD_AFFECTED_PERCENTAGE"
        value = "100"
      }
    }

    # Fault 2: Container kill
    faults {
      identity      = "container-kill"
      name          = "container-kill-5je"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = false

      values {
        name  = "TARGET_WORKLOAD_KIND"
        value = "deployment"
      }
      values {
        name  = "TARGET_WORKLOAD_NAMES"
        value = "abc"
      }
      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
      values {
        name  = "POD_AFFECTED_PERCENTAGE"
        value = "100"
      }
    }

    # Probes
    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-dxo-dxo"
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
      name          = "container-restart-check-w8u-w8u"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
    }

    # Complex multi-fault workflow
    vertices {
      name = "v-c5m"
      start {
        actions {
          name = "grafana-chaos-annotation-c3z-c3z"
        }
      }
      end {}
    }

    vertices {
      name = "v-5ky"
      start {
        faults {
          name = "container-kill-5je"
        }
      }
      end {
        actions {
          name = "grafana-chaos-annotation-c3z-c3z"
        }
      }
    }

    vertices {
      name = "v-wam"
      start {
        probes {
          name = "container-restart-check-w8u-w8u"
        }
      }
      end {
        faults {
          name = "container-kill-5je"
        }
      }
    }

    vertices {
      name = "v-djj"
      start {
        faults {
          name = "pod-network-loss-dhy"
        }
        probes {
          name = "pod-replica-count-check-dxo-dxo"
        }
      }
      end {
        probes {
          name = "container-restart-check-w8u-w8u"
        }
      }
    }

    vertices {
      name = "v-z3g"
      start {
        actions {
          name = "datadog-chaos-event-z1y-z1y"
        }
      }
      end {
        faults {
          name = "pod-network-loss-dhy"
        }
        probes {
          name = "pod-replica-count-check-dxo-dxo"
        }
      }
    }

    vertices {
      name = "v-end"
      start {}
      end {
        actions {
          name = "datadog-chaos-event-z1y-z1y"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Outputs
output "with_action_id" {
  description = "ID of experiment template with action"
  value       = length(harness_chaos_experiment_template.with_action) > 0 ? harness_chaos_experiment_template.with_action[0].id : null
}

output "two_actions_id" {
  description = "ID of experiment template with two actions"
  value       = length(harness_chaos_experiment_template.two_actions) > 0 ? harness_chaos_experiment_template.two_actions[0].id : null
}

output "multi_fault_id" {
  description = "ID of multi-fault experiment template"
  value       = length(harness_chaos_experiment_template.multi_fault) > 0 ? harness_chaos_experiment_template.multi_fault[0].id : null
}
