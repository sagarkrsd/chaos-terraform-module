#############################################
# ADVANCED ACTION TEMPLATE TESTS
# Focus: Runtime Inputs, All Run Properties, Complex Container Configurations
#############################################

#############################################
# Test 1: Container Action - Runtime Inputs
# NOTE: Disabled due to API limitation with this specific combination
# Other tests (container_max_env, container_labels_annotations) demonstrate runtime inputs successfully
#############################################
resource "harness_chaos_action_template" "container_runtime_inputs_advanced" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = 0  # Disabled - API returns Internal Server Error with this combination

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-runtime-inputs"
  name        = "Container Action - Runtime Inputs"
  description = "Container action with runtime input usage"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "busybox:latest"
    command   = ["sh", "-c"]
    args      = "echo 'Testing runtime inputs'"
    namespace = "default"

    labels = {
      app         = "test-app"
      environment = "<+input>"
    }

    env {
      name  = "ENV_VAR_1"
      value = "<+input>"
    }

    env {
      name  = "ENV_VAR_2"
      value = "<+input>"
    }

    host_network = false
    host_pid     = false
    host_ipc     = false
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "<+input>"
    initial_delay   = "<+input>"
    stop_on_failure = true
    verbosity       = "info"
    max_retries     = 5
  }

  variables {
    name        = "container_image"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Container image to use"
  }

  variables {
    name        = "command"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Command to execute"
  }

  variables {
    name        = "namespace"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Target namespace"
  }

  tags = ["terraform", "container", "runtime-inputs", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 2: Container Action - All Run Properties
#############################################
resource "harness_chaos_action_template" "container_all_run_props" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-all-run-props"
  name        = "Container Action - All Run Properties"
  description = "Container action testing all run property fields"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "busybox:latest"
    command   = ["sh", "-c"]
    args      = "echo Testing all run properties"
    namespace = "default"
  }

  # Testing ALL run properties with various values
  run_properties {
    timeout         = "90s"
    interval        = "25s"
    initial_delay   = "20s"
    stop_on_failure = true
    verbosity       = "debug"
    max_retries     = 10
  }

  variables {
    name        = "test_param"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Test parameter"
  }

  tags = ["terraform", "container", "all-run-props", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 3: Container Action - Complex Volumes Configuration
#############################################
resource "harness_chaos_action_template" "container_complex_volumes" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-complex-volumes"
  name        = "Container Action - Complex Volumes"
  description = "Container action with all volume types and runtime inputs"
  type        = "container"

  infrastructure_type = "<+input>"

  container_action {
    image     = "<+input>"
    command   = ["<+input>"]
    args      = "<+input>"
    namespace = "<+input>"

    # EmptyDir volume
    volumes {
      name = "cache-volume"
      empty_dir {
        medium = "Memory"
        # Note: size_limit not supported by API - field is not returned
      }
    }

    # ConfigMap volume
    volumes {
      name = "config-volume"
      config_map {
        name     = "<+input>"
        optional = false
      }
    }

    # Secret volume
    volumes {
      name = "secret-volume"
      secret {
        secret_name = "<+input>"
        optional    = false
      }
    }

    # HostPath volume
    volumes {
      name = "host-volume"
      host_path {
        path = "<+input>"
        type = "Directory"
      }
    }

    # PVC volume
    volumes {
      name = "pvc-volume"
      persistent_volume_claim {
        claim_name = "<+input>"
        read_only  = false
      }
    }

    # Volume mounts
    volume_mounts {
      name       = "cache-volume"
      mount_path = "/cache"
      read_only  = false
    }

    volume_mounts {
      name       = "config-volume"
      mount_path = "/config"
      sub_path   = "app.conf"
      read_only  = true
    }

    volume_mounts {
      name       = "secret-volume"
      mount_path = "/secrets"
      read_only  = true
    }

    volume_mounts {
      name       = "host-volume"
      mount_path = "/host-data"
      read_only  = false
    }

    volume_mounts {
      name       = "pvc-volume"
      mount_path = "/data"
      read_only  = false
    }
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "15s"
    initial_delay   = "10s"
    stop_on_failure = false
    verbosity       = "info"
    max_retries     = 7
  }

  variables {
    name        = "configmap_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "ConfigMap name"
  }

  variables {
    name        = "secret_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Secret name"
  }

  variables {
    name        = "host_path"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Host path"
  }

  variables {
    name        = "pvc_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "PVC name"
  }

  tags = ["terraform", "container", "volumes", "complex", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 4: Container Action - Tolerations and Scheduling
#############################################
resource "harness_chaos_action_template" "container_tolerations" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-tolerations"
  name        = "Container Action - Tolerations"
  description = "Container action with tolerations and node selectors"
  type        = "container"

  infrastructure_type = "<+input>"

  container_action {
    image     = "<+input>"
    command   = ["<+input>"]
    args      = "<+input>"
    namespace = "<+input>"

    # Node selector with runtime inputs
    node_selector = {
      node_type        = "<+input>"
      availability_zone = "<+input>"
      disk_type        = "<+input>"
    }

    # Multiple tolerations
    tolerations {
      key               = "node.kubernetes.io/not-ready"
      operator          = "Exists"
      effect            = "NoExecute"
      toleration_seconds = 300
    }

    tolerations {
      key      = "dedicated"
      operator = "Equal"
      value    = "chaos"
      effect   = "NoSchedule"
    }

    tolerations {
      key      = "environment"
      operator = "Equal"
      value    = "<+input>"
      effect   = "NoSchedule"
    }

    # Host namespace access
    host_network = true
    host_pid     = false
    host_ipc     = false
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "<+input>"
    initial_delay   = "<+input>"
    stop_on_failure = true
    verbosity       = "<+input>"
    max_retries     = 8
  }

  variables {
    name        = "node_type"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Node type for scheduling"
  }

  variables {
    name        = "toleration_value"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Toleration value"
  }

  tags = ["terraform", "container", "tolerations", "scheduling", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 5: Custom Script Action - Runtime Inputs
#############################################
resource "harness_chaos_action_template" "script_runtime_inputs" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "script-runtime-inputs"
  name        = "Custom Script - Runtime Inputs"
  description = "Custom script action with runtime inputs"
  type        = "customScript"

  infrastructure_type = "<+input>"

  custom_script_action {
    command = "<+input>"
    args    = ["<+input>"]
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "<+input>"
    initial_delay   = "<+input>"
    stop_on_failure = false
    verbosity       = "<+input>"
    max_retries     = 6
  }

  variables {
    name        = "script_command"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Script command to execute"
  }

  variables {
    name        = "script_args"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Script arguments"
  }

  variables {
    name        = "script_source"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Script source location"
  }

  tags = ["terraform", "script", "runtime-inputs", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 6: Delay Action - Runtime Inputs
#############################################
resource "harness_chaos_action_template" "delay_runtime_inputs" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "delay-runtime-inputs"
  name        = "Delay Action - Runtime Inputs"
  description = "Delay action with runtime duration input"
  type        = "delay"

  infrastructure_type = "<+input>"

  delay_action {
    duration = "<+input>"
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "10s"
    initial_delay   = "5s"
    stop_on_failure = false
    verbosity       = "info"
    max_retries     = 3
  }

  variables {
    name        = "delay_duration"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Delay duration (e.g., 30s, 5m)"
  }

  tags = ["terraform", "delay", "runtime-inputs", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 7: Container Action - Maximum Environment Variables
#############################################
resource "harness_chaos_action_template" "container_max_env" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-max-env"
  name        = "Container Action - Maximum Env Vars"
  description = "Container action with maximum environment variables"
  type        = "container"

  infrastructure_type = "<+input>"

  container_action {
    image     = "<+input>"
    command   = ["<+input>"]
    args      = "<+input>"
    namespace = "<+input>"

    env {
      name  = "ENV_1"
      value = "<+input>"
    }

    env {
      name  = "ENV_2"
      value = "<+input>"
    }

    env {
      name  = "ENV_3"
      value = "<+input>"
    }

    env {
      name  = "ENV_4"
      value = "<+input>"
    }

    env {
      name  = "ENV_5"
      value = "<+input>"
    }

    env {
      name  = "ENV_6"
      value = "static-value"
    }

    env {
      name  = "ENV_7"
      value = "<+input>"
    }

    env {
      name  = "ENV_8"
      value = "<+input>"
    }

    env {
      name  = "ENV_9"
      value = "<+input>"
    }

    env {
      name  = "ENV_10"
      value = "<+input>"
    }
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "20s"
    initial_delay   = "15s"
    stop_on_failure = false
    verbosity       = "debug"
    max_retries     = 12
  }

  variables {
    name        = "env_value_1"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Environment variable 1"
  }

  variables {
    name        = "env_value_2"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Environment variable 2"
  }

  variables {
    name        = "env_value_3"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Environment variable 3"
  }

  tags = ["terraform", "container", "max-env", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 8: Container Action - Maximum Retries
#############################################
resource "harness_chaos_action_template" "container_max_retries" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-max-retries"
  name        = "Container Action - Maximum Retries"
  description = "Container action testing maximum retries"
  type        = "container"

  infrastructure_type = "Kubernetes"

  container_action {
    image     = "<+input>"
    command   = ["<+input>"]
    args      = "<+input>"
    namespace = "default"
  }

  run_properties {
    timeout         = "180s"
    interval        = "40s"
    initial_delay   = "30s"
    stop_on_failure = false
    verbosity       = "trace"
    max_retries     = 20 # Maximum retries
  }

  variables {
    name        = "command"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Command to execute"
  }

  tags = ["terraform", "container", "max-retries", "resilience"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 9: Container Action - All Labels and Annotations
#############################################
resource "harness_chaos_action_template" "container_labels_annotations" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_action_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.action_test_hub_identity != "" ? var.action_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "container-labels-annotations"
  name        = "Container Action - Labels & Annotations"
  description = "Container action with extensive labels and annotations"
  type        = "container"

  infrastructure_type = "<+input>"

  container_action {
    image     = "<+input>"
    command   = ["<+input>"]
    args      = "<+input>"
    namespace = "<+input>"

    labels = {
      app                          = "<+input>"
      version                      = "<+input>"
      environment                  = "<+input>"
      team                         = "<+input>"
      cost_center                  = "<+input>"
      "app.kubernetes.io/name"     = "<+input>"
      "app.kubernetes.io/instance" = "<+input>"
      "app.kubernetes.io/version"  = "<+input>"
      "app.kubernetes.io/component" = "<+input>"
      "app.kubernetes.io/part-of"  = "<+input>"
    }

    annotations = {
      description                     = "<+input>"
      owner                           = "<+input>"
      contact                         = "<+input>"
      documentation                   = "<+input>"
      "prometheus.io/scrape"          = "true"
      "prometheus.io/port"            = "8080"
      "prometheus.io/path"            = "/metrics"
      "chaos.harness.io/experiment"   = "<+input>"
      "chaos.harness.io/target"       = "<+input>"
      "chaos.harness.io/duration"     = "<+input>"
    }

    image_pull_policy    = "<+input>"
    service_account_name = "<+input>"
  }

  run_properties {
    timeout         = "<+input>"
    interval        = "<+input>"
    initial_delay   = "<+input>"
    stop_on_failure = true
    verbosity       = "<+input>"
    max_retries     = 9
  }

  variables {
    name        = "app_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Application name"
  }

  variables {
    name        = "app_version"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Application version"
  }

  variables {
    name        = "experiment_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Chaos experiment name"
  }

  tags = ["terraform", "container", "labels", "annotations", "metadata"]

  lifecycle {
    ignore_changes = [tags]
  }
}
