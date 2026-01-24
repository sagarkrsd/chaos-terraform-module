# Probe Templates - ACCOUNT LEVEL
# ============================================================================
# Purpose: Comprehensive probe templates (HTTP, CMD, K8s) at ACCOUNT level
# Scope: No org_id, no project_id
# ============================================================================

# HTTP Probe - Account Level
resource "harness_chaos_probe_template" "http_account" {
  depends_on = [
    harness_chaos_hub_v2.account_level
  ]

  # Account level - no org_id or project_id
  hub_identity = harness_chaos_hub_v2.account_level[0].identity

  identity    = "http-get-complete-account"
  name        = "HTTP GET Probe - Complete Account"
  description = "HTTP probe with GET method and all validation fields"
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
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    initial_delay    = "5s"
    stop_on_failure  = true
    verbosity        = "info"
  }

  tags = ["terraform", "http", "get", "complete", "account"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# CMD Probe - Account Level
resource "harness_chaos_probe_template" "cmd_account" {
  depends_on = [
    harness_chaos_hub_v2.account_level
  ]

  # Account level - no org_id or project_id
  hub_identity = harness_chaos_hub_v2.account_level[0].identity

  identity    = "cmd-complete-account"
  name        = "CMD Probe - Complete Account"
  description = "CMD probe with all fields and comparators"
  type        = "cmdProbe"

  infrastructure_type = "Kubernetes"

  cmd_probe {
    command = "kubectl get pods -n default"
    source  = "inline"

    comparator {
      type     = "string"
      criteria = "contains"
      value    = "Running"
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    initial_delay    = "5s"
    stop_on_failure  = true
    verbosity        = "info"
  }

  tags = ["terraform", "cmd", "complete", "account"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# K8s Probe - Account Level
resource "harness_chaos_probe_template" "k8s_account" {
  depends_on = [
    harness_chaos_hub_v2.account_level
  ]

  # Account level - no org_id or project_id
  hub_identity = harness_chaos_hub_v2.account_level[0].identity

  identity    = "k8s-pods-with-selectors-account"
  name        = "K8s Pods Probe - With Selectors Account"
  description = "K8s probe for pods with label and field selectors"
  type        = "k8sProbe"

  infrastructure_type = "Kubernetes"

  k8s_probe {
    version        = "v1"
    resource       = "pods"
    namespace      = "default"
    label_selector = "app=nginx"
    field_selector = "status.phase=Running"
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    initial_delay    = "5s"
    stop_on_failure  = true
    verbosity        = "info"
  }

  tags = ["terraform", "k8s", "pods", "selectors", "account"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Outputs
output "http_probe_account_id" {
  description = "ID of HTTP probe (account level)"
  value       = harness_chaos_probe_template.http_account.id
}

output "cmd_probe_account_id" {
  description = "ID of CMD probe (account level)"
  value       = harness_chaos_probe_template.cmd_account.id
}

output "k8s_probe_account_id" {
  description = "ID of K8s probe (account level)"
  value       = harness_chaos_probe_template.k8s_account.id
}
