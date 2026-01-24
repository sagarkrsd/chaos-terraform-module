# ============================================================================
# Experiment Template Tests - Enterprise Hub Templates
# ============================================================================
# Purpose: Test experiment templates using enterprise hub fault/probe/action templates
# These templates already exist in the enterprise chaos hub
# ============================================================================

# ----------------------------------------------------------------------------
# Test 1: Simple - Only 1 Fault Template
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "simple_fault_only" {
  count = 1 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-simple-fault-only"
  name     = "tf-simple-fault-only"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level
  ]

  spec {
    infra_type = "KubernetesV2"

    # Single fault from enterprise hub
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
        name  = "TARGET_WORKLOAD_NAMESPACE"
        value = "<+input>"
      }
      values {
        name  = "TARGET_WORKLOAD_NAMES"
        value = "<+input>"
      }
      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
      values {
        name  = "NETWORK_PACKET_LOSS_PERCENTAGE"
        value = "<+input>"
      }
      values {
        name  = "POD_AFFECTED_PERCENTAGE"
        value = "100"
      }
      values {
        name  = "NETWORK_INTERFACE"
        value = "eth0"
      }
    }

    # Simple 2-vertex workflow
    vertices {
      name = "v-djj"
      start {
        faults {
          name = "pod-network-loss-dhy"
        }
      }
      end {}
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "pod-network-loss-dhy"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Test 2: Basic - 1 Fault + 1 Probe (Parallel)
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "fault_with_probe_parallel" {
  count = 1 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-fault-probe-parallel"
  name     = "tf-fault-probe-parallel"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level
  ]

  spec {
    infra_type = "KubernetesV2"

    # Fault from enterprise hub
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
        name  = "TARGET_WORKLOAD_NAMESPACE"
        value = "<+input>"
      }
      values {
        name  = "TOTAL_CHAOS_DURATION"
        value = "<+input>"
      }
    }

    # Probe from enterprise hub
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
      values {
        name  = "TARGET_KIND"
        value = "<+input>"
      }
      values {
        name  = "MINIMUM_HEALTHY_REPLICA_COUNT"
        value = "<+input>"
      }
      values {
        name  = "STATUS_CHECK_TIMEOUT"
        value = "180"
      }
      values {
        name  = "TIMEOUT"
        value = "180s"
      }
    }

    # Fault and probe run in parallel
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
      end {}
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
# Test 3: Intermediate - 1 Fault + 2 Probes (Parallel + Serial)
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "fault_with_two_probes" {
  count = 1 # Disabled by default - enable to test

  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-fault-two-probes"
  name     = "tf-fault-two-probes"

  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_hub_v2.project_level
  ]

  spec {
    infra_type = "KubernetesV2"

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

    # Probe 1: Pod replica count check
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
      values {
        name  = "MINIMUM_HEALTHY_REPLICA_COUNT"
        value = "<+input>"
      }
    }

    # Probe 2: Container restart check
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
      values {
        name  = "TARGET_CONTAINER"
        value = "<+input>"
      }
      values {
        name  = "TIMEOUT"
        value = "180s"
      }
    }

    # Vertex 1: Probe 2 runs first (serial)
    vertices {
      name = "v-wam"
      start {
        probes {
          name = "container-restart-check-w8u-w8u"
        }
      }
      end {}
    }

    # Vertex 2: Fault + Probe 1 run in parallel
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

    # Vertex 3: End
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

# Outputs
output "simple_fault_only_id" {
  description = "ID of simple fault-only experiment template"
  value       = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].id : null
}

output "fault_with_probe_parallel_id" {
  description = "ID of fault with probe (parallel) experiment template"
  value       = length(harness_chaos_experiment_template.fault_with_probe_parallel) > 0 ? harness_chaos_experiment_template.fault_with_probe_parallel[0].id : null
}

output "fault_with_two_probes_id" {
  description = "ID of fault with two probes experiment template"
  value       = length(harness_chaos_experiment_template.fault_with_two_probes) > 0 ? harness_chaos_experiment_template.fault_with_two_probes[0].id : null
}
