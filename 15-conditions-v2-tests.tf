# ============================================================================
# Step 15: conditions_v2 + enable_data_collection drift test
# ============================================================================
# Exercises the newer experiment-template features that were previously the
# source of perpetual "update in-place" diffs (provider fix: CHAOS-12144):
#
#   - spec.faults[].conditions_v2   { operator = AND|OR, values = [...] }
#   - spec.probes[].conditions_v2   { operator = AND|OR, values = [...] }
#   - spec.actions[].conditions_v2  { operator = AND|OR, values = [...] }
#   - spec.probes[].enable_data_collection = true
#
# conditions_v2 `values` are echoed back through the stored manifest, so they
# must round-trip exactly - including runtime inputs ("<+input>") - or the plan
# never converges.
#
# ---------------------------------------------------------------------------
# HOW TO VALIDATE THE DRIFT FIX (manual, requires a real apply):
#   1. terraform apply            # creates the template below
#   2. terraform plan             # MUST report "No changes." -> fix verified
# A non-empty second plan (e.g. conditions_v2 or enable_data_collection showing
# an in-place update) means the round-trip regressed.
# ---------------------------------------------------------------------------
# Composes the project-hub action/probe/fault templates (same ones used by
# 05-templates-project.tf's project_custom), so it is gated on those templates
# being enabled (local.create_conditions_v2_tests).

resource "harness_chaos_experiment_template" "conditions_v2" {
  count = local.create_conditions_v2_tests ? 1 : 0

  depends_on = [
    harness_chaos_action_template.project_level,
    harness_chaos_probe_template.project_level,
    harness_chaos_fault_template.project_level,
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity

  identity    = "e2econditionsv2template"
  name        = "e2e-conditions-v2-template"
  description = "Experiment template exercising conditions_v2 + enable_data_collection round-trip"
  tags        = ["e2e", "project", "conditions-v2"]

  spec {
    infra_type = "KubernetesV2"

    # Action with an AND condition using a runtime input.
    actions {
      identity               = local.action_template_project_identity
      name                   = "cv2-action"
      is_enterprise          = false
      continue_on_completion = false

      conditions_v2 {
        operator = "AND"
        values   = ["true", "<+input>"]
      }
    }

    # Fault with an OR condition (static + runtime input).
    faults {
      identity      = local.fault_template_project_identity
      name          = "cv2-fault"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false

      conditions_v2 {
        operator = "OR"
        values   = ["<+input>", "false"]
      }
    }

    # Probe with data collection enabled AND a conditions_v2 block - the exact
    # combination that previously produced a permanent diff.
    probes {
      identity               = local.probe_template_project_identity
      name                   = "cv2-probe"
      is_enterprise          = false
      weightage              = 10
      duration               = "15s"
      enable_data_collection = true

      conditions_v2 {
        operator = "AND"
        values   = ["<+input>"]
      }
    }

    vertices {
      name = "v-start"
      start {
        actions {
          name = "cv2-action"
        }
      }
    }

    vertices {
      name = "v-fault"
      start {
        faults {
          name = "cv2-fault"
        }
        probes {
          name = "cv2-probe"
        }
      }
    }

    vertices {
      name = "v-end"
      end {
        faults {
          name = "cv2-fault"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# ----------------------------------------------------------------------------
# Creation check via data source (identity round-trip)
# ----------------------------------------------------------------------------
data "harness_chaos_experiment_template" "verify_conditions_v2" {
  count = local.create_conditions_v2_tests ? 1 : 0

  depends_on = [harness_chaos_experiment_template.conditions_v2]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity
  identity     = harness_chaos_experiment_template.conditions_v2[0].identity
}

output "conditions_v2_template" {
  description = "conditions_v2 + enable_data_collection experiment template details"
  value = local.create_conditions_v2_tests ? {
    id                = try(harness_chaos_experiment_template.conditions_v2[0].id, "")
    identity          = try(harness_chaos_experiment_template.conditions_v2[0].identity, "")
    verified_identity = try(data.harness_chaos_experiment_template.verify_conditions_v2[0].identity, "")
  } : null
}
