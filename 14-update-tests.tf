# ============================================================================
# Step 14: Update Tests (variable-driven, two-apply)
# ============================================================================
# Exercises each chaos resource's UPDATE code path WITHOUT editing files
# between applies. Resources here are dedicated/isolated (a dedicated
# update-test hub + project scope) so they never disturb the main e2e suite.
#
# WORKFLOW:
#   1. terraform apply                                   # phase = "initial"
#   2. terraform apply -var='update_test_phase=updated'  # in-place UPDATE
#
# Every mutable field switches on local.ut_updated. Immutable (ForceNew)
# fields (identity, type, hub_identity, scope) stay constant so the second
# apply is an in-place UPDATE, not a replace.
#
# Coverage: hub_v2, action/probe(http,cmd,k8s)/fault/experiment templates,
# security_governance_condition_v3 / _rule_v3. Infrastructure and image
# registry updates are driven on their MAIN resources (06-infrastructure.tf,
# test-image-registry.tf) via local.update_test_updated, since both are
# scoped singletons that cannot be safely duplicated.
#
# NOTE: the `//`-commented "INITIAL" blocks below are legacy manual examples,
# superseded by the toggle.
# ============================================================================

locals {
  ut_updated          = local.update_test_updated
  update_hub_identity = local.create_update_tests ? harness_chaos_hub_v2.update_test[0].identity : ""
}

# ----------------------------------------------------------------------------
# Chaos Hub (dedicated) - update test
# ----------------------------------------------------------------------------
resource "harness_chaos_hub_v2" "update_test" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [harness_platform_project.this]

  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  identity    = "e2e-update-hub"
  name        = local.ut_updated ? "E2E Update Test Hub (updated)" : "E2E Update Test Hub"
  description = local.ut_updated ? "UPDATED: dedicated hub for update tests" : "Dedicated hub for update tests"

  tags = local.ut_updated ? ["e2e", "update-test", "hub", "updated"] : ["e2e", "update-test", "hub"]
}

# ----------------------------------------------------------------------------
# Action Template - update test
# ----------------------------------------------------------------------------
resource "harness_chaos_action_template" "update_test" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [harness_chaos_hub_v2.update_test]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity

  identity            = "e2e-update-action"
  name                = local.ut_updated ? "E2E Update Action (updated)" : "E2E Update Action"
  description         = local.ut_updated ? "UPDATED action template" : "Initial action template"
  type                = "delay"
  infrastructure_type = "KubernetesV2"
  tags                = local.ut_updated ? ["e2e", "update-test", "action", "updated"] : ["e2e", "update-test", "action"]

  delay_action {
    duration = local.ut_updated ? "20s" : "10s"
  }

  run_properties {
    timeout  = local.ut_updated ? "3m" : "2m"
    interval = "1s"
  }
}

// # ----------------------------------------------------------------------------
// # Update Test 1: HTTP Probe - Basic Field Updates
// # Tests: name, description, tags, run_properties, http_probe fields
// # ----------------------------------------------------------------------------
// resource "harness_chaos_probe_template" "update_test_http" {
//   depends_on = [harness_chaos_hub_v2.update_test]

//   # Immutable fields (ForceNew)
//   org_id       = harness_platform_organization.this.id
//   project_id   = harness_platform_project.this.id
//   hub_identity = local.update_hub_identity
//   identity     = "e2e-update-test-http"
//   type         = "httpProbe"

//   # ===== INITIAL VALUES =====
//   # To test updates:
//   # 1. Apply with these values first
//   # 2. Then change to UPDATED VALUES below
//   # 3. Apply again and verify changes

//   name        = "E2E HTTP Probe Update Test - Initial"
//   description = "Initial description for update testing"
//   tags        = ["e2e", "update-test", "http", "initial"]

//   infrastructure_type = "Kubernetes"

//   http_probe {
//     url = "https://httpbin.org/status/200"

//     method {
//       get {
//         criteria      = "=="
//         response_code = "200"
//       }
//     }
//   }

//   run_properties {
//     timeout          = "30s"
//     interval         = "10s"
//     polling_interval = "2s"
//     initial_delay    = "5s"
//     stop_on_failure  = false
//     verbosity        = "info"
//   }

//   variables {
//     name        = "test_url"
//     value       = "<+input>"
//     type        = "string"
//     required    = false
//     description = "Test URL (runtime input)"
//   }
// }

# ===== UPDATED VALUES (Uncomment to test updates) =====
# After initial apply succeeds, comment out the resource above
# and uncomment this one to test updates

resource "harness_chaos_probe_template" "update_test_http" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [harness_chaos_hub_v2.update_test]

  # Immutable fields (same)
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity
  identity     = "e2e-update-test-http"
  type         = "httpProbe"

  # ===== UPDATED VALUES =====
  name        = "E2E HTTP Probe Update Test - UPDATED"
  description = local.ut_updated ? "UPDATED: HTTP probe update test" : "Initial: HTTP probe update test"
  tags        = local.ut_updated ? ["e2e", "update-test", "http", "updated"] : ["e2e", "update-test", "http"]

  infrastructure_type = "KubernetesV2" # Changed

  http_probe {
    url = "https://httpbin.org/status/201" # Changed

    method {
      get {
        criteria      = "=="
        response_code = "201" # Changed
        response_body = ""    # Added
      }
    }
  }

  run_properties {
    timeout          = "45s"   # Changed
    interval         = "15s"   # Changed
    polling_interval = "3s"    # Changed
    initial_delay    = "10s"   # Changed
    stop_on_failure  = true    # Changed
    verbosity        = "debug" # Changed
    attempt          = 3       # Added
    retry            = 2       # Added
  }

  variables {
    name        = "test_url"
    value       = "<+input>"
    type        = "string"
    required    = true                                # Changed
    description = "UPDATED: Test URL (runtime input)" # Changed
  }

  variables {
    name        = "timeout_override" # Added new variable
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Override timeout value"
  }
}


// # ----------------------------------------------------------------------------
// # Update Test 2: CMD Probe - All Field Updates
// # Tests: command, comparator, env variables, run_properties
// # ----------------------------------------------------------------------------
// resource "harness_chaos_probe_template" "update_test_cmd" {
//   depends_on = [harness_chaos_hub_v2.update_test]

//   org_id       = harness_platform_organization.this.id
//   project_id   = harness_platform_project.this.id
//   hub_identity = local.update_hub_identity
//   identity     = "e2e-update-test-cmd"
//   type         = "cmdProbe"

//   # ===== INITIAL VALUES =====
//   name        = "E2E CMD Probe Update Test - Initial"
//   description = "Initial CMD probe for update testing"
//   tags        = ["e2e", "update-test", "cmd"]

//   infrastructure_type = "Kubernetes"

//   cmd_probe {
//     command = "echo 'initial'"
//     source  = "inline"

//     comparator {
//       type     = "string"
//       criteria = "=="
//       value    = "initial"
//     }

//     env {
//       name  = "TEST_VAR"
//       value = "initial_value"
//     }
//   }

//   run_properties {
//     timeout  = "20s"
//     interval = "5s"
//   }

//   variables {
//     name        = "command_output"
//     value       = "initial"
//     type        = "string"
//     required    = false
//     description = "Expected command output"
//   }
// }

# ===== UPDATED VERSION (Uncomment to test) =====

resource "harness_chaos_probe_template" "update_test_cmd" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [harness_chaos_hub_v2.update_test]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity
  identity     = "e2e-update-test-cmd"
  type         = "cmdProbe"

  # ===== UPDATED VALUES =====
  name        = "E2E CMD Probe Update Test - UPDATED"
  description = local.ut_updated ? "UPDATED: CMD probe update test" : "Initial: CMD probe update test"
  tags        = local.ut_updated ? ["e2e", "update-test", "cmd", "updated"] : ["e2e", "update-test", "cmd"]

  infrastructure_type = "KubernetesV2"

  cmd_probe {
    command = "echo 'updated'" # Changed
    # source omitted = inline execution. Do NOT set source = "inline" (string):
    # the backend unmarshals cmd probe source into a SourceDetails object, so a
    # scalar string fails experiment execution.

    comparator {
      type     = "string"
      criteria = "contains" # Changed
      value    = "updated"  # Changed
    }

    env {
      name  = "TEST_VAR"
      value = "updated_value" # Changed
    }

    env {
      name  = "NEW_VAR" # Added
      value = "new_value"
    }
  }

  run_properties {
    timeout         = "30s" # Changed
    interval        = "10s" # Changed
    attempt         = 5     # Added
    retry           = 3     # Added
    stop_on_failure = true  # Added
  }

  variables {
    name        = "command_output"
    value       = "updated" # Changed
    type        = "string"
    required    = true                               # Changed
    description = "UPDATED: Expected command output" # Changed
  }

  variables {
    name        = "retry_count" # Added
    value       = "3"
    type        = "number"
    required    = false
    description = "Number of retries"
  }
}

// # ----------------------------------------------------------------------------
// # Update Test 3: K8s Probe - Resource and Selector Updates
// # Tests: resource type, namespace, selectors, operation
// # ----------------------------------------------------------------------------
// resource "harness_chaos_probe_template" "update_test_k8s" {
//   depends_on = [harness_chaos_hub_v2.update_test]

//   org_id       = harness_platform_organization.this.id
//   project_id   = harness_platform_project.this.id
//   hub_identity = local.update_hub_identity
//   identity     = "e2e-update-test-k8s"
//   type         = "k8sProbe"

//   # ===== INITIAL VALUES =====
//   name        = "E2E K8s Probe Update Test - Initial"
//   description = "Initial K8s probe for update testing"
//   tags        = ["e2e", "update-test", "k8s"]

//   infrastructure_type = "Kubernetes"

//   k8s_probe {
//     version        = "v1"
//     resource       = "pods"
//     namespace      = "default"
//     label_selector = "app=nginx"
//   }

//   run_properties {
//     timeout  = "30s"
//     interval = "10s"
//   }
// }

# ===== UPDATED VERSION (Uncomment to test) =====

resource "harness_chaos_probe_template" "update_test_k8s" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [harness_chaos_hub_v2.update_test]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity
  identity     = "e2e-update-test-k8s"
  type         = "k8sProbe"

  # ===== UPDATED VALUES =====
  name        = "E2E K8s Probe Update Test - UPDATED"
  description = local.ut_updated ? "UPDATED: K8s probe update test" : "Initial: K8s probe update test"
  tags        = local.ut_updated ? ["e2e", "update-test", "k8s", "updated"] : ["e2e", "update-test", "k8s"]

  infrastructure_type = "KubernetesV2"

  k8s_probe {
    group          = "apps" # Added
    version        = "v1"
    resource       = "deployments"        # Changed
    namespace      = "kube-system"        # Changed
    label_selector = "app=updated"        # Changed
    field_selector = "metadata.name=test" # Added
    operation      = "present"            # Added
  }

  run_properties {
    timeout         = "60s"   # Changed
    interval        = "20s"   # Changed
    stop_on_failure = true    # Added
    verbosity       = "debug" # Added
  }

  variables {
    name        = "namespace" # Added
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Kubernetes namespace to check"
  }
}


# ----------------------------------------------------------------------------
# Validation: Verify Update Test Probes via Data Source
# ----------------------------------------------------------------------------

data "harness_chaos_probe_template" "verify_update_http" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [
    harness_chaos_probe_template.update_test_http
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity
  identity     = try(harness_chaos_probe_template.update_test_http[0].identity, "")
}

data "harness_chaos_probe_template" "verify_update_cmd" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [
    harness_chaos_probe_template.update_test_cmd
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity
  identity     = try(harness_chaos_probe_template.update_test_cmd[0].identity, "")
}

data "harness_chaos_probe_template" "verify_update_k8s" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [
    harness_chaos_probe_template.update_test_k8s
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity
  identity     = try(harness_chaos_probe_template.update_test_k8s[0].identity, "")
}

# ----------------------------------------------------------------------------
# Fault Template - update test (UPDATE-via-PUT path; must not 500, no drift)
# ----------------------------------------------------------------------------
resource "harness_chaos_fault_template" "update_test" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [harness_chaos_hub_v2.update_test]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity

  identity             = "e2e-update-fault"
  name                 = local.ut_updated ? "E2E Update Fault (updated)" : "E2E Update Fault"
  description          = local.ut_updated ? "UPDATED fault template" : "Initial fault template"
  category             = ["Kubernetes"]
  infrastructures      = ["KubernetesV2"]
  type                 = "Custom"
  permissions_required = "Basic"
  tags                 = local.ut_updated ? ["e2e", "update-test", "fault", "updated"] : ["e2e", "update-test", "fault"]

  variables {
    name        = "CHAOS_DURATION"
    description = "Duration of chaos in seconds"
    type        = "string"
    value       = local.ut_updated ? "<+input>.default('30')" : "<+input>.default('20')"
  }

  links {
    name = "Documentation"
    url  = "https://docs.harness.io"
  }

  spec {
    chaos {
      fault_name = "byoc-injector"

      params {
        name  = "CHAOS_DURATION"
        value = local.ut_updated ? "30s" : "20s"
      }
      params {
        name  = "CHAOS_INTERVAL"
        value = "5s"
      }

      kubernetes {
        image             = "chaosnative/go-runner:ci"
        command           = ["/bin/bash", "-c"]
        args              = ["echo 'update-test fault'; sleep 20"]
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
# Experiment Template (custom) - update test
# References the dedicated update-test action/probe/fault (same hub). An
# experiment TEMPLATE only references templates; it does not instantiate
# fault/probe/action instances, so it destroys cleanly.
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "update_test" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [
    harness_chaos_action_template.update_test,
    harness_chaos_probe_template.update_test_cmd,
    harness_chaos_fault_template.update_test,
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.update_hub_identity

  identity    = "e2e-update-exp"
  name        = local.ut_updated ? "E2E Update Experiment (updated)" : "E2E Update Experiment"
  description = local.ut_updated ? "UPDATED experiment template" : "Initial experiment template"
  tags        = local.ut_updated ? ["e2e", "update-test", "exp", "updated"] : ["e2e", "update-test", "exp"]

  spec {
    infra_type = "KubernetesV2"

    actions {
      identity               = "e2e-update-action"
      name                   = "upd-action"
      is_enterprise          = false
      continue_on_completion = false
    }

    faults {
      identity      = "e2e-update-fault"
      name          = "upd-fault"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
    }

    probes {
      identity      = "e2e-update-test-cmd"
      name          = "upd-probe"
      is_enterprise = false
      weightage     = 10
      duration      = "20s"
    }

    vertices {
      name = "v-start"
      start {
        actions {
          name = "upd-action"
        }
      }
    }

    vertices {
      name = "v-fault"
      start {
        probes {
          name = "upd-probe"
        }
        faults {
          name = "upd-fault"
        }
      }
      end {
        actions {
          name = "upd-action"
        }
      }
    }

    vertices {
      name = "v-end"
      end {
        probes {
          name = "upd-probe"
        }
        faults {
          name = "upd-fault"
        }
      }
    }

    cleanup_policy = local.ut_updated ? "retain" : "delete"
  }
}

# ----------------------------------------------------------------------------
# Security Governance V3 - update test (condition + rule)
# Toggles operator (EQUAL_TO <-> NOT_EQUAL_TO), namespace_labels, description,
# is_enabled and tags so the second apply exercises the condition/rule UPDATE.
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "update_test" {
  count = local.create_update_tests && local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-update-cond"
  description = local.ut_updated ? "UPDATED: v3 update-test condition" : "Initial: v3 update-test condition"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  infra_type  = "KubernetesV2"

  fault_spec {
    operator = "EQUAL_TO"
    faults {
      fault_type = "FAULT"
      name       = "*"
    }
  }

  k8s_spec {
    infra_spec {
      operator  = "EQUAL_TO"
      infra_ids = ["${harness_platform_environment.this.id}/${try(harness_chaos_infrastructure_v2.this[0].id, "")}"]
    }

    application_spec {
      operator = local.ut_updated ? "NOT_EQUAL_TO" : "EQUAL_TO"

      workloads {
        kind      = "*"
        label     = "*"
        namespace = ""

        namespace_labels = local.ut_updated ? { "environment" = "staging" } : { "environment" = "production" }
      }
    }

    chaos_service_account_spec {
      operator         = "EQUAL_TO"
      service_accounts = ["*"]
    }
  }

  lifecycle {
    ignore_changes = [name]
  }
}

resource "harness_chaos_security_governance_rule_v3" "update_test" {
  count = local.create_update_tests && local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_chaos_security_governance_condition_v3.update_test,
  ]

  name        = "test-v3-update-rule"
  description = local.ut_updated ? "UPDATED: v3 update-test rule" : "Initial: v3 update-test rule"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  is_enabled  = local.ut_updated ? false : true
  tags        = local.ut_updated ? ["managed-by=terraform", "api=v3", "updated"] : ["managed-by=terraform", "api=v3"]

  condition_ids  = [harness_chaos_security_governance_condition_v3.update_test[0].id]
  user_group_ids = var.security_governance_rule_user_group_ids

  time_windows {
    time_zone  = "UTC"
    start_time = 1756616940000
    duration   = "30m"

    recurrence {
      type  = "None"
      until = -1
    }
  }

  lifecycle {
    ignore_changes = [name]
  }
}

# ----------------------------------------------------------------------------
# Outputs for Update Tests
# ----------------------------------------------------------------------------

// output "update_test_probes" {
//   description = "Update test probe template details"
//   value = {
//     http_probe = {
//       id          = harness_chaos_probe_template.update_test_http[0].id
//       identity    = try(harness_chaos_probe_template.update_test_http[0].identity, "")
//       name        = harness_chaos_probe_template.update_test_http[0].name
//       description = harness_chaos_probe_template.update_test_http[0].description
//       revision    = harness_chaos_probe_template.update_test_http[0].revision
//       tags        = harness_chaos_probe_template.update_test_http[0].tags
//     }
//     cmd_probe = {
//       id          = harness_chaos_probe_template.update_test_cmd[0].id
//       identity    = try(harness_chaos_probe_template.update_test_cmd[0].identity, "")
//       name        = harness_chaos_probe_template.update_test_cmd[0].name
//       description = harness_chaos_probe_template.update_test_cmd[0].description
//       revision    = harness_chaos_probe_template.update_test_cmd[0].revision
//       tags        = harness_chaos_probe_template.update_test_cmd[0].tags
//     }
//     k8s_probe = {
//       id          = harness_chaos_probe_template.update_test_k8s[0].id
//       identity    = try(harness_chaos_probe_template.update_test_k8s[0].identity, "")
//       name        = harness_chaos_probe_template.update_test_k8s[0].name
//       description = harness_chaos_probe_template.update_test_k8s[0].description
//       revision    = harness_chaos_probe_template.update_test_k8s[0].revision
//       tags        = harness_chaos_probe_template.update_test_k8s[0].tags
//     }
//   }
// }

output "update_test_verification" {
  description = "Verification data for update tests"
  value = {
    http_verified = {
      name     = try(data.harness_chaos_probe_template.verify_update_http[0].name, "")
      revision = try(data.harness_chaos_probe_template.verify_update_http[0].revision, "")
    }
    cmd_verified = {
      name     = try(data.harness_chaos_probe_template.verify_update_cmd[0].name, "")
      revision = try(data.harness_chaos_probe_template.verify_update_cmd[0].revision, "")
    }
    k8s_verified = {
      name     = try(data.harness_chaos_probe_template.verify_update_k8s[0].name, "")
      revision = try(data.harness_chaos_probe_template.verify_update_k8s[0].revision, "")
    }
  }
}

output "update_test_phase_active" {
  description = "Active update-test phase and whether the 'updated' values are applied"
  value = {
    phase   = var.update_test_phase
    updated = local.ut_updated
  }
}

output "update_test_resource_ids" {
  description = "IDs of the dedicated update-test resources (empty unless enable_update_tests)"
  value = {
    hub        = try(harness_chaos_hub_v2.update_test[0].id, "")
    action     = try(harness_chaos_action_template.update_test[0].id, "")
    fault      = try(harness_chaos_fault_template.update_test[0].id, "")
    experiment = try(harness_chaos_experiment_template.update_test[0].id, "")
    gov_cond   = try(harness_chaos_security_governance_condition_v3.update_test[0].id, "")
    gov_rule   = try(harness_chaos_security_governance_rule_v3.update_test[0].id, "")
  }
}
