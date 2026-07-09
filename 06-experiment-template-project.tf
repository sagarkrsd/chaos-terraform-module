# ============================================================================
# Step 5: Complex Experiment Template - Project Level
# ============================================================================
# This template demonstrates a complex chaos experiment with:
# - 2 Enterprise Faults (pod-delete, pod-network-latency)
# - 4 Enterprise Probes (pod-status-check x2, pod-replica-count-check x2)
# - 3 Workflow Vertices with start/end phases
# - Runtime inputs (<+input>) for flexibility
# ============================================================================

resource "harness_chaos_experiment_template" "project_complex" {
  count = local.create_experiment_templates && var.enable_project_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_hub_v2.project_level,
    harness_chaos_action_template.project_level,
  ]

  # Project level
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity

  identity    = "e2echaosexperimenttemplate"
  name        = "e2e-chaos-experiment-template"
  description = "Complex E2E experiment template with multiple faults and probes"
  tags        = ["e2e", "project", "complex", "enterprise"]

  spec {
    infra_type = "KubernetesV2"

    # ----------------------------------------------------------------------------
    # Action: custom (non-enterprise) action template from the project hub.
    # Action-template coverage lives in this NORMAL (enterprise-fault) template
    # on purpose - see "Action-template coverage & teardown safety" in README.md.
    # ----------------------------------------------------------------------------
    actions {
      identity               = local.action_template_project_identity
      name                   = "project-action"
      is_enterprise          = false
      continue_on_completion = false
    }

    # ----------------------------------------------------------------------------
    # Fault 1: Pod Delete
    # ----------------------------------------------------------------------------
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

    # ----------------------------------------------------------------------------
    # Fault 2: Pod Network Latency
    # ----------------------------------------------------------------------------
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

    # ----------------------------------------------------------------------------
    # Probe 1: Pod Status Check (nic-nic)
    # ----------------------------------------------------------------------------
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

    # ----------------------------------------------------------------------------
    # Probe 2: Pod Replica Count Check (d9a-d9a)
    # ----------------------------------------------------------------------------
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

    # ----------------------------------------------------------------------------
    # Probe 3: Pod Replica Count Check (1ox-1ox)
    # ----------------------------------------------------------------------------
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

    # ----------------------------------------------------------------------------
    # Probe 4: Pod Status Check (ua4-ua4)
    # ----------------------------------------------------------------------------
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

    # ----------------------------------------------------------------------------
    # Workflow Vertex 1: v-jrc (Start Phase)
    # Runs pod-delete with status and replica checks
    # ----------------------------------------------------------------------------
    vertices {
      name = "v-jrc"

      start {
        actions {
          name = "project-action"
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

    # ----------------------------------------------------------------------------
    # Workflow Vertex 2: v-qn1 (Start and End Phases)
    # Start: Runs network latency with replica and status checks
    # End: Runs pod-delete again with status and replica checks
    # ----------------------------------------------------------------------------
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

    # ----------------------------------------------------------------------------
    # Workflow Vertex 3: v-end (End Phase)
    # Runs network latency again with replica and status checks
    # ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# Output
# ----------------------------------------------------------------------------
output "complex_experiment_template_id" {
  description = "ID of the complex experiment template"
  value       = local.exp_template_project_complex_id
}

output "complex_experiment_template_identity" {
  description = "Identity of the complex experiment template"
  value       = local.exp_template_project_complex_identity
}
