# ============================================================================
# Experiment Template Test - Exact UI Match
# ============================================================================
# Purpose: Create an experiment template that exactly matches the UI-created format
# This validates our implementation produces the same output as the UI
# ============================================================================

resource "harness_chaos_experiment_template" "ui_match_test" {
  org_id       = harness_platform_organization.this[0].id
  project_id   = harness_platform_project.this[0].id
  hub_identity = harness_chaos_hub_v2.project_level[0].identity

  identity = "tf-ui-match-test"
  name     = "tf-ui-match-test"

  # Ensure proper creation sequence
  depends_on = [
    harness_chaos_infrastructure_v2.this,
    harness_chaos_fault_template.comprehensive,
    harness_chaos_action_template.delay_simple,
    harness_chaos_action_template.script_custom,
    harness_chaos_probe_template.http_get_complete,
    harness_chaos_probe_template.cmd_complete
  ]

  spec {
    infra_type = "KubernetesV2"

    faults {
      identity      = harness_chaos_fault_template.comprehensive.identity
      name          = "tf-comprehensive-test-vxv"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
      # Empty values array - UI shows values: []
    }

    # Probes - matching UI format exactly
    probes {
      identity  = harness_chaos_probe_template.http_get_complete[0].identity
      name      = "http-get-complete-91r-91r"
      is_enterprise = false
      weightage = 10
      duration  = "30s"
      # Empty values array
    }

    probes {
      identity  = harness_chaos_probe_template.cmd_complete[0].identity
      name      = "cmd-complete-jkz-jkz"
      is_enterprise = false
      weightage = 10
      duration  = "30s"
      # Empty values array
    }

    # Actions - matching UI format exactly
    actions {
      identity               = harness_chaos_action_template.script_custom[0].identity
      name                   = "script-custom-uzm-uzm"
      is_enterprise          = false
      continue_on_completion = false

      values {
        name  = "namespace"
        value = "<+input>"
      }
    }

    actions {
      identity               = harness_chaos_action_template.delay_simple[0].identity
      name                   = "delay-simple-dpf-dpf"
      is_enterprise          = false
      continue_on_completion = false
      # Empty values array
    }

    # Vertices - matching UI format exactly
    vertices {
      name = "v-jms"

      start {
        probes {
          name = "cmd-complete-jkz-jkz"
        }
        actions {
          name = "script-custom-uzm-uzm"
        }
      }

      end {}
    }

    vertices {
      name = "v-vzs"

      start {
        probes {
          name = "http-get-complete-91r-91r"
        }
        faults {
          name = "tf-comprehensive-test-vxv"
        }
      }

      end {
        probes {
          name = "cmd-complete-jkz-jkz"
        }
        actions {
          name = "script-custom-uzm-uzm"
        }
      }
    }

    vertices {
      name = "v-du9"

      start {
        actions {
          name = "delay-simple-dpf-dpf"
        }
      }

      end {
        probes {
          name = "http-get-complete-91r-91r"
        }
        faults {
          name = "tf-comprehensive-test-vxv"
        }
      }
    }

    vertices {
      name = "v-end"

      start {}

      end {
        actions {
          name = "delay-simple-dpf-dpf"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Outputs for verification
output "ui_match_experiment_id" {
  description = "ID of UI match test experiment"
  value       = harness_chaos_experiment_template.ui_match_test.id
}

output "ui_match_experiment_identity" {
  description = "Identity of UI match test experiment"
  value       = harness_chaos_experiment_template.ui_match_test.identity
}

output "ui_match_experiment_name" {
  description = "Name of UI match test experiment"
  value       = harness_chaos_experiment_template.ui_match_test.name
}
