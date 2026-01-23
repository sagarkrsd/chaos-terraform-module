#############################################
# ADVANCED PROBE TEMPLATE TESTS
# Focus: Runtime Inputs, All Run Properties, Complex Configurations
#############################################

#############################################
# Test 1: HTTP Probe - Runtime Inputs
# NOTE: Disabled due to API limitation with this specific combination
# Other tests (http_runtime_inputs, http_minimal_runtime) demonstrate runtime inputs successfully
#############################################
resource "harness_chaos_probe_template" "http_runtime_inputs_advanced" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = 0  # Disabled - API returns Internal Server Error with this combination

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "http-runtime-inputs"
  name        = "HTTP Probe - Runtime Inputs"
  description = "HTTP probe with runtime input usage"
  type        = "httpProbe"

  infrastructure_type = "Kubernetes"

  http_probe {
    url = "https://httpbin.org/status/200"

    method {
      get {
        criteria      = "=="
        response_code = "200"
        response_body = ""
      }
    }
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "<+input>"
    polling_interval = "2s"
    initial_delay    = "5s"
    stop_on_failure  = false
    verbosity        = "info"
    attempt          = 5
    retry            = 3
  }

  variables {
    name        = "target_url"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Target URL for probe"
  }

  variables {
    name        = "expected_code"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Expected HTTP response code"
  }

  variables {
    name        = "timeout_duration"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Timeout duration"
  }

  tags = ["terraform", "runtime-inputs", "http", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 2: CMD Probe - All Run Properties
#############################################
resource "harness_chaos_probe_template" "cmd_all_run_props" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "cmd-all-run-props"
  name        = "CMD Probe - All Run Properties"
  description = "CMD probe testing all run property fields"
  type        = "cmdProbe"

  infrastructure_type = "Kubernetes"

  cmd_probe {
    command = "curl -s -o /dev/null -w '%%{http_code}' https://httpbin.org/status/200"
    source  = "inline"

    comparator {
      type     = "string"
      criteria = "equal"
      value    = "200"
    }

    env {
      name  = "HTTP_TIMEOUT"
      value = "30"
    }

    env {
      name  = "RETRY_COUNT"
      value = "<+input>"
    }
  }

  # Testing ALL run properties with various values
  run_properties {
    timeout          = "60s"
    interval         = "15s"
    polling_interval = "5s"
    initial_delay    = "10s"
    stop_on_failure  = true
    verbosity        = "debug"
    attempt          = 10
    retry            = 5
  }

  variables {
    name        = "command"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Command to execute"
  }

  variables {
    name        = "expected_output"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Expected command output"
  }

  tags = ["terraform", "cmd", "all-run-props", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 3: K8s Probe - Complex Selectors with Runtime Inputs
#############################################
resource "harness_chaos_probe_template" "k8s_complex_selectors" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "k8s-complex-selectors"
  name        = "K8s Probe - Complex Selectors"
  description = "K8s probe with complex selectors and runtime inputs"
  type        = "k8sProbe"

  infrastructure_type = "<+input>"

  k8s_probe {
    group          = "apps"
    version        = "v1"
    resource       = "deployments"
    namespace      = "<+input>"
    label_selector = "<+input>"
    field_selector = "<+input>"
    resource_names = "<+input>"
    operation      = "present"
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "<+input>"
    polling_interval = "3s"
    initial_delay    = "5s"
    stop_on_failure  = false
    verbosity        = "info"
    attempt          = 3
    retry            = 2
  }

  variables {
    name        = "namespace"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Target namespace"
  }

  variables {
    name        = "label_selector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Label selector for resources"
  }

  variables {
    name        = "field_selector"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Field selector for resources"
  }

  variables {
    name        = "resource_names"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Specific resource names"
  }

  tags = ["terraform", "k8s", "complex", "selectors", "runtime-inputs"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 4: HTTP POST Probe - All Fields with Runtime Inputs
#############################################
resource "harness_chaos_probe_template" "http_post_advanced" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "http-post-advanced"
  name        = "HTTP POST Probe - Advanced"
  description = "HTTP POST probe with all fields and runtime inputs"
  type        = "httpProbe"

  infrastructure_type = "<+input>"

  http_probe {
    url = "<+input>"

    method {
      post {
        criteria      = "=="
        response_code = "<+input>"
        response_body = "<+input>"
        body          = "<+input>"
        content_type  = "<+input>"
      }
    }
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "<+input>"
    polling_interval = "<+input>"
    initial_delay    = "<+input>"
    stop_on_failure  = true
    verbosity        = "<+input>"
    attempt          = 7
    retry            = 4
  }

  variables {
    name        = "api_endpoint"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "API endpoint URL"
  }

  variables {
    name        = "request_body"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "POST request body"
  }

  variables {
    name        = "content_type"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Content-Type header"
  }

  variables {
    name        = "expected_response"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Expected response body"
  }

  tags = ["terraform", "http", "post", "advanced", "runtime-inputs"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 5: CMD Probe - Multiple Environment Variables
#############################################
resource "harness_chaos_probe_template" "cmd_multi_env" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "cmd-multi-env"
  name        = "CMD Probe - Multiple Env Vars"
  description = "CMD probe with multiple environment variables and runtime inputs"
  type        = "cmdProbe"

  infrastructure_type = "<+input>"

  cmd_probe {
    command = "<+input>"
    source  = "inline"

    comparator {
      type     = "string"
      criteria = "contains"
      value    = "<+input>"
    }

    env {
      name  = "ENV_VAR_1"
      value = "<+input>"
    }

    env {
      name  = "ENV_VAR_2"
      value = "<+input>"
    }

    env {
      name  = "ENV_VAR_3"
      value = "<+input>"
    }

    env {
      name  = "ENV_VAR_4"
      value = "static-value"
    }

    env {
      name  = "ENV_VAR_5"
      value = "<+input>"
    }
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "20s"
    polling_interval = "4s"
    initial_delay    = "8s"
    stop_on_failure  = false
    verbosity        = "trace"
    attempt          = 8
    retry            = 6
  }

  variables {
    name        = "command_to_run"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Command to execute"
  }

  variables {
    name        = "env_var_1"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Environment variable 1"
  }

  variables {
    name        = "env_var_2"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Environment variable 2"
  }

  variables {
    name        = "expected_output"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Expected output pattern"
  }

  tags = ["terraform", "cmd", "multi-env", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 6: K8s Probe - All Operations Testing
#############################################
resource "harness_chaos_probe_template" "k8s_all_operations" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "k8s-all-operations"
  name        = "K8s Probe - All Operations"
  description = "K8s probe testing different operations with runtime inputs"
  type        = "k8sProbe"

  infrastructure_type = "<+input>"

  k8s_probe {
    group          = "<+input>"
    version        = "<+input>"
    resource       = "<+input>"
    namespace      = "<+input>"
    label_selector = "<+input>"
    field_selector = "<+input>"
    resource_names = "<+input>"
    operation      = "<+input>" # Can be: present, absent, create, delete
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "<+input>"
    polling_interval = "<+input>"
    initial_delay    = "<+input>"
    stop_on_failure  = true
    verbosity        = "<+input>"
    attempt          = 15
    retry            = 10
  }

  variables {
    name        = "resource_group"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "K8s resource group"
  }

  variables {
    name        = "resource_version"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "K8s resource version"
  }

  variables {
    name        = "resource_type"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "K8s resource type"
  }

  variables {
    name        = "operation_type"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Operation to perform (present/absent/create/delete)"
  }

  tags = ["terraform", "k8s", "all-operations", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 7: HTTP Probe - Minimal Runtime Inputs (Edge Case)
#############################################
resource "harness_chaos_probe_template" "http_minimal_runtime" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "http-minimal-runtime"
  name        = "HTTP Probe - Minimal Runtime"
  description = "HTTP probe with minimal runtime inputs (edge case testing)"
  type        = "httpProbe"

  infrastructure_type = "Kubernetes"

  http_probe {
    url = "<+input>" # Only URL as runtime input

    method {
      get {
        criteria      = "=="
        response_code = "200"
        response_body = ""
      }
    }
  }

  run_properties {
    timeout  = "30s"
    interval = "10s"
    attempt  = 3
    retry    = 2
  }

  variables {
    name        = "url"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Target URL"
  }

  tags = ["terraform", "http", "minimal-runtime", "edge-case"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 8: CMD Probe - Maximum Attempts and Retries
#############################################
resource "harness_chaos_probe_template" "cmd_max_attempts" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "cmd-max-attempts"
  name        = "CMD Probe - Maximum Attempts"
  description = "CMD probe testing maximum attempts and retries"
  type        = "cmdProbe"

  infrastructure_type = "Kubernetes"

  cmd_probe {
    command = "<+input>"
    source  = "inline"

    comparator {
      type     = "int"
      criteria = "=="
      value    = "<+input>"
    }
  }

  run_properties {
    timeout          = "120s"
    interval         = "30s"
    polling_interval = "10s"
    initial_delay    = "15s"
    stop_on_failure  = false
    verbosity        = "debug"
    attempt          = 20 # Maximum attempts
    retry            = 15 # Maximum retries
  }

  variables {
    name        = "command"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Command to execute"
  }

  variables {
    name        = "expected_value"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Expected integer value"
  }

  tags = ["terraform", "cmd", "max-attempts", "resilience"]

  lifecycle {
    ignore_changes = [tags]
  }
}
