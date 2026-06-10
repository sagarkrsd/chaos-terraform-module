# ============================================================================
# Step 4a: Account-Level Templates
# ============================================================================

# ----------------------------------------------------------------------------
# 1. Action Template - Account Level
# ----------------------------------------------------------------------------
resource "harness_chaos_action_template" "account_level" {
  count = local.create_action_templates && var.enable_account_scope_resources ? 1 : 0

  depends_on = [harness_chaos_hub_v2.account_level]

  # Account level - no org_id or project_id
  hub_identity = local.account_hub_identity

  identity            = "e2e-action-account"
  name                = "E2E Action Template Account"
  description         = "Account-level action template for E2E test"
  type                = "customScript"
  infrastructure_type = "KubernetesV2"
  tags                = ["e2e", "account", "action"]

  # Custom script action
  custom_script_action {
    command = "bash"
    args    = ["-c", "echo 'Account-level action executing...'; sleep 5; echo 'Account-level action completed'"]
  }

  # Run properties
  run_properties {
    timeout  = "5m"
    interval = "2s"
  }
}

# ----------------------------------------------------------------------------
# 2. Probe Template - Account Level
# ----------------------------------------------------------------------------
resource "harness_chaos_probe_template" "account_level" {
  count = local.create_probe_templates && var.enable_account_scope_resources ? 1 : 0

  depends_on = [harness_chaos_hub_v2.account_level]

  # Account level - no org_id or project_id
  hub_identity = local.account_hub_identity

  identity            = "e2e-probe-account"
  name                = "E2E Probe Template Account"
  description         = "Account-level probe template for E2E test"
  type                = "httpProbe"
  infrastructure_type = "KubernetesV2"
  tags                = ["e2e", "account", "probe"]

  # HTTP probe
  http_probe {
    url = "https://httpbin.org/status/200"

    method {
      get {
        criteria      = "=="
        response_code = "200"
      }
    }
  }

  # Run properties
  run_properties {
    timeout          = "5s"
    interval         = "2s"
    polling_interval = "1s"
    stop_on_failure  = false
  }
}

# ----------------------------------------------------------------------------
# 3. Fault Template - Account Level
# ----------------------------------------------------------------------------
resource "harness_chaos_fault_template" "account_level" {
  count = local.create_fault_templates && var.enable_account_scope_resources ? 1 : 0

  depends_on = [harness_chaos_hub_v2.account_level]

  # Account level - no org_id or project_id
  hub_identity = local.account_hub_identity

  identity             = "e2e-fault-account"
  name                 = "E2E Fault Template Account"
  description          = "Account-level fault template for E2E test"
  category             = ["Kubernetes"]
  infrastructures      = ["KubernetesV2"]
  type                 = "Custom"
  permissions_required = "Basic"
  tags                 = ["e2e", "account", "fault"]

  links {
    name = "Documentation"
    url  = "https://docs.harness.io"
  }

  spec {
    chaos {
      fault_name = "byoc-injector"

      params {
        name  = "CHAOS_DURATION"
        value = "30s"
      }
      params {
        name  = "CHAOS_INTERVAL"
        value = "10s"
      }

      kubernetes {
        image             = "chaosnative/go-runner:ci"
        command           = ["/bin/bash", "-c"]
        args              = ["echo 'Account-level fault running'; sleep 30"]
        image_pull_policy = "IfNotPresent"

        resources {
          limits = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }
    }
  }
}

# ----------------------------------------------------------------------------
# 4. Experiment Template (Custom) - Account Level
# Uses custom action, probe, and fault templates from account hub
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "account_custom" {
  count = local.create_experiment_templates && var.enable_account_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_action_template.account_level,
    harness_chaos_probe_template.account_level,
    harness_chaos_fault_template.account_level
  ]

  # Account level - no org_id or project_id
  hub_identity = local.account_hub_identity

  identity    = "e2e-exp-account-custom"
  name        = "E2E Experiment Template Account Custom"
  description = "Account-level experiment template using custom templates"
  tags        = ["e2e", "account", "custom"]

  spec {
    infra_type = "KubernetesV2"

    # Action from account hub
    actions {
      identity               = local.action_template_account_identity
      name                   = "account-action"
      is_enterprise          = false
      continue_on_completion = false
    }

    # Fault from account hub
    faults {
      identity      = local.fault_template_account_identity
      name          = "account-fault"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
    }

    # Probe from account hub
    probes {
      identity      = local.probe_template_account_identity
      name          = "account-probe"
      is_enterprise = false
      weightage     = 10
      duration      = "30s"
    }

    # Workflow vertices
    vertices {
      name = "v-start"
      start {
        actions {
          name = "account-action"
        }
      }
    }

    vertices {
      name = "v-fault"
      start {
        faults {
          name = "account-fault"
        }
        probes {
          name = "account-probe"
        }
      }
    }

    vertices {
      name = "v-end"
      end {
        faults {
          name = "account-fault"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Enterprise experiment template removed - using complex template instead
# See: 02-experiment-template-complex-account.tf
