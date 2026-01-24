# ============================================================================
# Experiment Template Tests - Advanced Multi-Cloud Scenarios
# ============================================================================
# Purpose: Test very complex experiment templates with K8s + AWS faults/probes
# Using enterprise hub templates
# ============================================================================

# ----------------------------------------------------------------------------
# Test 7: Very Complex - 3 Faults (K8s + AWS) + 2 Actions + 2 Probes
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "multi_cloud_complex" {
  count = 0 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-multi-cloud-complex"
  name     = "tf-multi-cloud-complex"

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
      values {
        name  = "MODE"
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
    }

    # Fault 3: EC2 stop (AWS)
    faults {
      identity      = "ec2-stop-by-id"
      name          = "ec2-stop-by-id-rf6"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = true

      values {
        name  = "ASSUME_ROLE_ARN"
        value = "<+input>"
      }
      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
      values {
        name  = "REGION"
        value = "<+input>"
      }
      values {
        name  = "EC2_INSTANCE_ID"
        value = "<+input>"
      }
    }

    # Probe 1: Pod replica count (K8s)
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

    # Probe 2: Container restart (K8s)
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

    # Complex multi-cloud workflow
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
      name = "v-rgp"
      start {
        faults {
          name = "ec2-stop-by-id-rf6"
        }
      }
      end {
        actions {
          name = "datadog-chaos-event-z1y-z1y"
        }
      }
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "ec2-stop-by-id-rf6"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Test 8: Most Complex - 3 Faults + 2 Actions + 3 Probes (K8s + AWS)
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "most_complex" {
  count = 0 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-most-complex"
  name     = "tf-most-complex"

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

    # Faults
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
    }

    faults {
      identity      = "ec2-stop-by-id"
      name          = "ec2-stop-by-id-rf6"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = true

      values {
        name  = "REGION"
        value = "<+input>"
      }
      values {
        name  = "EC2_INSTANCE_ID"
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

    # AWS probe
    probes {
      identity      = "aws-ec2-instance-status-check"
      name          = "aws-ec2-instance-status-check-lzn-lzn"
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
      values {
        name  = "ATTEMPT"
        value = "1"
      }
      values {
        name  = "VERBOSITY"
        value = "info"
      }
    }

    # Most complex workflow with 7 vertices
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
        probes {
          name = "aws-ec2-instance-status-check-lzn-lzn"
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
      name = "v-rgp"
      start {
        faults {
          name = "ec2-stop-by-id-rf6"
        }
      }
      end {
        actions {
          name = "datadog-chaos-event-z1y-z1y"
        }
        probes {
          name = "aws-ec2-instance-status-check-lzn-lzn"
        }
      }
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "ec2-stop-by-id-rf6"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Outputs
output "multi_cloud_complex_id" {
  description = "ID of multi-cloud complex experiment template"
  value       = length(harness_chaos_experiment_template.multi_cloud_complex) > 0 ? harness_chaos_experiment_template.multi_cloud_complex[0].id : null
}

output "most_complex_id" {
  description = "ID of most complex experiment template"
  value       = length(harness_chaos_experiment_template.most_complex) > 0 ? harness_chaos_experiment_template.most_complex[0].id : null
}
