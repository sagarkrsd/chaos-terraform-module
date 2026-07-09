# ============================================================================
# Step 2b: Complex Experiment Template - Account Level
# ============================================================================
# Replicates the complex experiment template at account level
# ============================================================================

resource "harness_chaos_experiment_template" "account_complex" {
  count = local.create_experiment_templates && var.enable_account_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_hub_v2.account_level,
    harness_chaos_action_template.account_level,
  ]

  # Account level - no org_id or project_id
  hub_identity = local.account_hub_identity

  identity    = "e2echaosexperimenttemplate-account"
  name        = "e2e-chaos-experiment-template-account"
  description = "Complex E2E experiment template at account level with multiple faults and probes"
  tags        = ["e2e", "account", "complex", "enterprise"]

  spec {
    infra_type = "KubernetesV2"

    # Action-template coverage lives in this NORMAL (enterprise-fault) template
    # on purpose - see "Action-template coverage & teardown safety" in README.md.
    actions {
      identity               = local.action_template_account_identity
      name                   = "account-action"
      is_enterprise          = false
      continue_on_completion = false
    }

    # Fault 1: Pod Delete
    faults {
      identity      = "pod-delete"
      name          = "pod-delete-jpu"
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
        name  = "CHAOS_INTERVAL"
        value = "<+input>"
      }
      values {
        name  = "POD_AFFECTED_PERCENTAGE"
        value = "<+input>"
      }
      values {
        name  = "NODE_LABEL"
        value = "<+input>"
      }
    }

    # Fault 2: Pod Network Latency
    faults {
      identity      = "pod-network-latency"
      name          = "pod-network-latency-ql6"
      revision      = "v1"
      is_enterprise = true
      auth_enabled  = false

      values {
        name  = "TARGET_WORKLOAD_KIND"
        value = "<+input>"
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
        name  = "NETWORK_LATENCY"
        value = "<+input>"
      }
      values {
        name  = "POD_AFFECTED_PERCENTAGE"
        value = "<+input>"
      }
    }

    # Probe 1: Pod Status Check (nic-nic)
    probes {
      identity      = "pod-status-check"
      name          = "pod-status-check-nic-nic"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_LABELS"
        value = "<+input>"
      }
      values {
        name  = "TARGET_NAMES"
        value = "<+input>"
      }
      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
      values {
        name  = "TARGET_KIND"
        value = "<+input>"
      }
      values {
        name  = "ATTEMPT"
        value = "<+input>"
      }
      values {
        name  = "INTERVAL"
        value = "<+input>"
      }
    }

    # Probe 2: Pod Replica Count Check (d9a-d9a)
    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-d9a-d9a"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_LABELS"
        value = "<+input>"
      }
      values {
        name  = "TARGET_NAMES"
        value = "<+input>"
      }
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
        name  = "ATTEMPT"
        value = "<+input>"
      }
    }

    # Probe 3: Pod Replica Count Check (1ox-1ox)
    probes {
      identity      = "pod-replica-count-check"
      name          = "pod-replica-count-check-1ox-1ox"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMES"
        value = "<+input>"
      }
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
    }

    # Probe 4: Pod Status Check (ua4-ua4)
    probes {
      identity      = "pod-status-check"
      name          = "pod-status-check-ua4-ua4"
      is_enterprise = true
      weightage     = 10
      duration      = "30s"

      values {
        name  = "TARGET_NAMES"
        value = "<+input>"
      }
      values {
        name  = "TARGET_NAMESPACE"
        value = "<+input>"
      }
      values {
        name  = "TARGET_KIND"
        value = "<+input>"
      }
    }

    # Workflow Vertex 1: v-jrc (Start Phase)
    vertices {
      name = "v-jrc"

      start {
        actions {
          name = "account-action"
        }
        faults {
          name = "pod-delete-jpu"
        }
        probes {
          name = "pod-status-check-nic-nic"
        }
        probes {
          name = "pod-replica-count-check-d9a-d9a"
        }
      }
    }

    # Workflow Vertex 2: v-qn1 (Start and End Phases)
    vertices {
      name = "v-qn1"

      start {
        faults {
          name = "pod-network-latency-ql6"
        }
        probes {
          name = "pod-replica-count-check-1ox-1ox"
        }
        probes {
          name = "pod-status-check-ua4-ua4"
        }
      }

      end {
        faults {
          name = "pod-delete-jpu"
        }
        probes {
          name = "pod-status-check-nic-nic"
        }
        probes {
          name = "pod-replica-count-check-d9a-d9a"
        }
      }
    }

    # Workflow Vertex 3: v-end (End Phase)
    vertices {
      name = "v-end"

      end {
        faults {
          name = "pod-network-latency-ql6"
        }
        probes {
          name = "pod-replica-count-check-1ox-1ox"
        }
        probes {
          name = "pod-status-check-ua4-ua4"
        }
      }
    }
  }
}

# Output
output "account_complex_experiment_template_id" {
  description = "ID of the account-level complex experiment template"
  value       = local.exp_template_account_complex_id
}

output "account_complex_experiment_template_identity" {
  description = "Identity of the account-level complex experiment template"
  value       = local.exp_template_account_complex_identity
}
