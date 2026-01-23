# Action Template Comprehensive Test Cases
#############################################
# This file contains comprehensive test cases for Action Templates
# covering delay actions, script actions, and container actions with all fields

#############################################
# Delay Action Tests
#############################################

# Test 1: Simple Delay Action
resource "harness_chaos_action_template" "delay_simple" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "delay-simple"
  name        = "Simple Delay Action"
  description = "Basic delay action with 30 second duration"
  type        = "delay"

  infrastructure_type = "Kubernetes"

  delay_action {
    duration = "30s"
  }

  run_properties {
    timeout  = "60s"
    interval = "10s"
  }

  tags = ["terraform", "delay", "simple"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Script Action Tests
#############################################

# Test 2: Custom Script Action
resource "harness_chaos_action_template" "script_custom" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "script-custom"
  name        = "Custom Script Action"
  description = "Script action with custom bash commands"
  type        = "customScript"

  infrastructure_type = "Kubernetes"

  custom_script_action {
    command = "bash"
    args    = ["-c", "echo 'Starting custom script'; kubectl get pods -n default; echo 'Script completed'"]
  }

  run_properties {
    timeout         = "120s"
    interval        = "30s"
    stop_on_failure = true
  }

  variables {
    name        = "namespace"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Kubernetes namespace"
  }

  tags = ["terraform", "script", "custom"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Container Action Tests - Basic
#############################################

# Test 3: Container Action - Basic
resource "harness_chaos_action_template" "container_basic" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-basic"
  name        = "Basic Container Action"
  description = "Container action with basic configuration"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "busybox:latest"
    command   = ["sh", "-c"]
    args      = "echo 'Hello from container'; sleep 10"
    namespace = "default"
  }

  run_properties {
    timeout  = "60s"
    interval = "15s"
  }

  tags = ["terraform", "container", "basic"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Test 4: Container Action - With Environment Variables
resource "harness_chaos_action_template" "container_with_env" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-with-env"
  name        = "Container with Environment Variables"
  description = "Container action with environment variables"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "alpine:latest"
    command   = ["sh", "-c"]
    args      = "echo $TEST_VAR; echo $ANOTHER_VAR"
    namespace = "default"

    env {
      name  = "TEST_VAR"
      value = "test_value"
    }

    env {
      name  = "ANOTHER_VAR"
      value = "another_value"
    }
  }

  run_properties {
    timeout  = "90s"
    interval = "20s"
  }

  tags = ["terraform", "container", "env"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Test 5: Container Action - With Resource Limits
resource "harness_chaos_action_template" "container_with_resources" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-with-resources"
  name        = "Container with Resource Limits"
  description = "Container action with CPU and memory limits"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "nginx:alpine"
    namespace = "default"

    resources {
      limits = {
        cpu    = "500m"
        memory = "512Mi"
      }

      requests = {
        cpu    = "250m"
        memory = "256Mi"
      }
    }
  }

  run_properties {
    timeout  = "120s"
    interval = "30s"
  }

  tags = ["terraform", "container", "resources"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Test 6: Container Action - With Labels and Annotations
resource "harness_chaos_action_template" "container_with_labels" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-with-labels"
  name        = "Container with Labels and Annotations"
  description = "Container action with labels and annotations"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "busybox:latest"
    command   = ["sleep", "30"]
    namespace = "default"

    labels = {
      app         = "chaos-test"
      environment = "testing"
      managed-by  = "terraform"
    }

    annotations = {
      description = "Chaos engineering test container"
      owner       = "chaos-team"
    }
  }

  run_properties {
    timeout  = "60s"
    interval = "15s"
  }

  tags = ["terraform", "container", "labels"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Test 7: Container Action - With Node Selector
resource "harness_chaos_action_template" "container_with_node_selector" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-with-node-selector"
  name        = "Container with Node Selector"
  description = "Container action with node selector for pod placement"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "alpine:latest"
    command   = ["sh", "-c", "echo 'Running on selected node'; sleep 20"]
    namespace = "default"

    node_selector = {
      disktype = "ssd"
      zone     = "us-west-1a"
    }
  }

  run_properties {
    timeout  = "90s"
    interval = "20s"
  }

  tags = ["terraform", "container", "node-selector"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Test 8: Container Action - With Service Account
resource "harness_chaos_action_template" "container_with_sa" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-with-sa"
  name        = "Container with Service Account"
  description = "Container action with Kubernetes service account"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image                = "bitnami/kubectl:latest"
    command              = ["kubectl", "get", "pods"]
    namespace            = "default"
    service_account_name = "chaos-service-account"
  }

  run_properties {
    timeout  = "60s"
    interval = "15s"
  }

  tags = ["terraform", "container", "service-account"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Test 9: Container Action - With Image Pull Policy
resource "harness_chaos_action_template" "container_with_pull_policy" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-with-pull-policy"
  name        = "Container with Image Pull Policy"
  description = "Container action with Always pull policy"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image             = "nginx:latest"
    namespace         = "default"
    image_pull_policy = "Always"
  }

  run_properties {
    timeout  = "120s"
    interval = "30s"
  }

  tags = ["terraform", "container", "pull-policy"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Test 10: Container Action - With Runtime Inputs
resource "harness_chaos_action_template" "container_runtime_inputs" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-runtime-inputs"
  name        = "Container with Runtime Inputs"
  description = "Container action with runtime input support"
  type        = "container"

  infrastructure_type = "<+input>.default('Kubernetes')"

  container_action {
    image     = "<+input>.default('busybox:latest')"
    command   = ["<+input>.default('sh')"]
    namespace = "<+input>.default('default')"
  }

  run_properties {
    timeout  = "<+input>.default('60s')"
    interval = "<+input>.default('15s')"
  }

  variables {
    name        = "container_image"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Container image to use (runtime input)"
  }

  variables {
    name        = "namespace"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Kubernetes namespace (runtime input)"
  }

  tags = ["terraform", "container", "runtime"]

  lifecycle {
    ignore_changes = [tags]
  }
}
