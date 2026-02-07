# ============================================================================
# Step 4b: Org-Level Templates
# ============================================================================

# ----------------------------------------------------------------------------
# 1. Action Template - Org Level
# ----------------------------------------------------------------------------
resource "harness_chaos_action_template" "org_level" {
  depends_on = [harness_chaos_hub_v2.org_level]

  # Org level - org_id only
  org_id       = harness_platform_organization.this.id
  hub_identity = harness_chaos_hub_v2.org_level.identity

  identity            = "e2e-action-org"
  name                = "E2E Action Template Org"
  description         = "Org-level action template for E2E test"
  type                = "delay"
  infrastructure_type = "KubernetesV2"
  tags                = ["e2e", "org", "action"]

  # Delay action
  delay_action {
    duration = "10s"
  }

  # Run properties
  run_properties {
    timeout  = "2m"
    interval = "1s"
  }
}

# ----------------------------------------------------------------------------
# 2. Probe Template - Org Level
# ----------------------------------------------------------------------------
resource "harness_chaos_probe_template" "org_level" {
  depends_on = [harness_chaos_hub_v2.org_level]

  # Org level - org_id only
  org_id       = harness_platform_organization.this.id
  hub_identity = harness_chaos_hub_v2.org_level.identity

  identity            = "e2e-probe-org"
  name                = "E2E Probe Template Org"
  description         = "Org-level probe template for E2E test"
  type                = "cmdProbe"
  infrastructure_type = "KubernetesV2"
  tags                = ["e2e", "org", "probe"]

  # CMD probe
  cmd_probe {
    command = "echo 'Org-level probe check'; exit 0"
    source  = "inline"
  }

  # Run properties
  run_properties {
    timeout          = "10s"
    interval         = "3s"
    polling_interval = "1s"
    stop_on_failure  = false
  }
}

# ----------------------------------------------------------------------------
# 3. Fault Template - Org Level
# ----------------------------------------------------------------------------
resource "harness_chaos_fault_template" "org_level" {
  depends_on = [harness_chaos_hub_v2.org_level]

  # Org level - org_id only
  org_id       = harness_platform_organization.this.id
  hub_identity = harness_chaos_hub_v2.org_level.identity

  identity             = "e2e-fault-org"
  name                 = "E2E Fault Template Org"
  description          = "Org-level fault template for E2E test"
  category             = ["Kubernetes"]
  infrastructures      = ["KubernetesV2"]
  type                 = "Custom"
  permissions_required = "Basic"
  tags                 = ["e2e", "org", "fault"]

  links {
    name = "Documentation"
    url  = "https://docs.harness.io"
  }

  spec {
    chaos {
      fault_name = "byoc-injector"

      params {
        name  = "CHAOS_DURATION"
        value = "20s"
      }
      params {
        name  = "CHAOS_INTERVAL"
        value = "5s"
      }

      kubernetes {
        image             = "chaosnative/go-runner:ci"
        command           = ["/bin/bash", "-c"]
        args              = ["echo 'Org-level fault running'; sleep 20"]
        image_pull_policy = "IfNotPresent"

        resources {
          limits = {
            cpu    = "200m"
            memory = "200Mi"
          }
        }
      }
    }
  }
}

# ----------------------------------------------------------------------------
# 4. Experiment Template (Custom) - Org Level
# Uses custom action, probe, and fault templates from org hub
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "org_custom" {
  depends_on = [
    harness_chaos_action_template.org_level,
    harness_chaos_probe_template.org_level,
    harness_chaos_fault_template.org_level
  ]

  # Org level - org_id only
  org_id       = harness_platform_organization.this.id
  hub_identity = harness_chaos_hub_v2.org_level.identity

  identity    = "e2e-exp-org-custom"
  name        = "E2E Experiment Template Org Custom"
  description = "Org-level experiment template using custom templates"
  tags        = ["e2e", "org", "custom"]

  spec {
    infra_type = "KubernetesV2"

    # Action from org hub
    actions {
      identity               = harness_chaos_action_template.org_level.identity
      name                   = "org-action"
      is_enterprise          = false
      continue_on_completion = false
    }

    # Fault from org hub
    faults {
      identity      = harness_chaos_fault_template.org_level.identity
      name          = "org-fault"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
    }

    # Probe from org hub
    probes {
      identity      = harness_chaos_probe_template.org_level.identity
      name          = "org-probe"
      is_enterprise = false
      weightage     = 10
      duration      = "20s"
    }

    # Workflow vertices
    vertices {
      name = "v-start"
      start {
        actions {
          name = "org-action"
        }
      }
      end {}
    }

    vertices {
      name = "v-fault"
      start {
        faults {
          name = "org-fault"
        }
        probes {
          name = "org-probe"
        }
      }
      end {}
    }

    vertices {
      name = "v-end"
      start {}
      end {
        faults {
          name = "org-fault"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Enterprise experiment template removed - using complex template instead
# See: 03-experiment-template-complex-org.tf
