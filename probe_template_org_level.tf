# Probe Templates - ORG LEVEL
# ============================================================================
# Purpose: Comprehensive probe templates (HTTP, CMD, K8s) at ORG level
# Scope: org_id only, no project_id
# ============================================================================

# HTTP Probe - Org Level
resource "harness_chaos_probe_template" "http_org" {
  depends_on = [
    harness_chaos_hub_v2.org_level
  ]

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity    = "http-get-complete-org"
  name        = "HTTP GET Probe - Complete Org"
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

  tags = ["terraform", "http", "get", "complete", "org"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# CMD Probe - Org Level
resource "harness_chaos_probe_template" "cmd_org" {
  depends_on = [
    harness_chaos_hub_v2.org_level
  ]

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity    = "cmd-complete-org"
  name        = "CMD Probe - Complete Org"
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

  tags = ["terraform", "cmd", "complete", "org"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# K8s Probe - Org Level
resource "harness_chaos_probe_template" "k8s_org" {
  depends_on = [
    harness_chaos_hub_v2.org_level
  ]

  # Org level - org_id only
  org_id       = harness_platform_organization.this[0].id
  hub_identity = harness_chaos_hub_v2.org_level[0].identity

  identity    = "k8s-pods-with-selectors-org"
  name        = "K8s Pods Probe - With Selectors Org"
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

  tags = ["terraform", "k8s", "pods", "selectors", "org"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Outputs
output "http_probe_org_id" {
  description = "ID of HTTP probe (org level)"
  value       = harness_chaos_probe_template.http_org.id
}

output "cmd_probe_org_id" {
  description = "ID of CMD probe (org level)"
  value       = harness_chaos_probe_template.cmd_org.id
}

output "k8s_probe_org_id" {
  description = "ID of K8s probe (org level)"
  value       = harness_chaos_probe_template.k8s_org.id
}
