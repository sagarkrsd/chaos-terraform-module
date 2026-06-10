# ============================================================================
# Step 14: Update Tests for Probe Templates
# ============================================================================
# These tests verify that probe template updates work correctly
# Based on analysis from terraform-provider-harness investigation
#
# TESTING APPROACH:
# 1. Initial apply creates probe templates with initial values
# 2. Modify this file to change values (see UPDATED sections below)
# 3. Re-apply to test updates
# 4. Verify changes in Harness UI and check for drift
#
# KNOWN LIMITATIONS:
# - HTTP probe headers/auth/tls_config are NOT supported (will be ignored)
# - Terraform may show drift even after successful updates (known SDK issue)
# ============================================================================

// # ----------------------------------------------------------------------------
// # Update Test 1: HTTP Probe - Basic Field Updates
// # Tests: name, description, tags, run_properties, http_probe fields
// # ----------------------------------------------------------------------------
// resource "harness_chaos_probe_template" "update_test_http" {
//   depends_on = [harness_chaos_hub_v2.project_level]

//   # Immutable fields (ForceNew)
//   org_id       = harness_platform_organization.this.id
//   project_id   = harness_platform_project.this.id
//   hub_identity = local.project_hub_identity
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

  depends_on = [harness_chaos_hub_v2.project_level]

  # Immutable fields (same)
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity
  identity     = "e2e-update-test-http"
  type         = "httpProbe"

  # ===== UPDATED VALUES =====
  name        = "E2E HTTP Probe Update Test - UPDATED"
  description = "UPDATED: Description changed to verify update functionality"
  tags        = ["e2e", "update-test", "http", "updated", "verified"]

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
//   depends_on = [harness_chaos_hub_v2.project_level]

//   org_id       = harness_platform_organization.this.id
//   project_id   = harness_platform_project.this.id
//   hub_identity = local.project_hub_identity
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

  depends_on = [harness_chaos_hub_v2.project_level]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity
  identity     = "e2e-update-test-cmd"
  type         = "cmdProbe"

  # ===== UPDATED VALUES =====
  name        = "E2E CMD Probe Update Test - UPDATED"
  description = "UPDATED: CMD probe with changed values"
  tags        = ["e2e", "update-test", "cmd", "updated"]

  infrastructure_type = "KubernetesV2"

  cmd_probe {
    command = "echo 'updated'" # Changed
    source  = "inline"

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
//   depends_on = [harness_chaos_hub_v2.project_level]

//   org_id       = harness_platform_organization.this.id
//   project_id   = harness_platform_project.this.id
//   hub_identity = local.project_hub_identity
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

  depends_on = [harness_chaos_hub_v2.project_level]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity
  identity     = "e2e-update-test-k8s"
  type         = "k8sProbe"

  # ===== UPDATED VALUES =====
  name        = "E2E K8s Probe Update Test - UPDATED"
  description = "UPDATED: K8s probe with changed resource type and selectors"
  tags        = ["e2e", "update-test", "k8s", "updated"]

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
  hub_identity = local.project_hub_identity
  identity     = try(harness_chaos_probe_template.update_test_http[0].identity, "")
}

data "harness_chaos_probe_template" "verify_update_cmd" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [
    harness_chaos_probe_template.update_test_cmd
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity
  identity     = try(harness_chaos_probe_template.update_test_cmd[0].identity, "")
}

data "harness_chaos_probe_template" "verify_update_k8s" {
  count = local.create_update_tests ? 1 : 0

  depends_on = [
    harness_chaos_probe_template.update_test_k8s
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity
  identity     = try(harness_chaos_probe_template.update_test_k8s[0].identity, "")
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
