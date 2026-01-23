#############################################
# APM PROBE TEMPLATE COMPREHENSIVE TESTS
# Testing all 7 APM provider types with various configurations
#############################################

#############################################
# Test 1: Prometheus APM Probe - Basic
#############################################
resource "harness_chaos_probe_template" "apm_prometheus_basic" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-prometheus-basic"
  name        = "APM Prometheus - Basic"
  description = "Prometheus APM probe for monitoring metrics"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Prometheus"

    comparator {
      type     = "float"
      criteria = "<="
      value    = "100"
    }

    prometheus_inputs {
      connector_id = "<+input>"
      query        = "up{job='api-server'}"
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    stop_on_failure  = false
    verbosity        = "info"
  }

  variables {
    name        = "prometheus_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Prometheus connector ID"
  }

  variables {
    name        = "threshold"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Metric threshold value"
  }

  tags = ["terraform", "apm", "prometheus", "basic"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 2: Prometheus APM Probe - With TLS Config
#############################################
resource "harness_chaos_probe_template" "apm_prometheus_tls" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-prometheus-tls"
  name        = "APM Prometheus - TLS Enabled"
  description = "Prometheus APM probe with TLS configuration"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Prometheus"

    comparator {
      type     = "float"
      criteria = "<"
      value    = "95.5"
    }

    prometheus_inputs {
      connector_id = "<+input>"
      query        = "rate(http_requests_total[5m])"

      tls_config {
        ca_cert_secret       = "<+input>"
        client_cert_secret   = "<+input>"
        client_key_secret    = "<+input>"
        insecure_skip_verify = false
      }
    }
  }

  run_properties {
    timeout          = "45s"
    interval         = "15s"
    polling_interval = "3s"
    initial_delay    = "5s"
    stop_on_failure  = true
    verbosity        = "debug"
    attempt          = 5
    retry            = 3
  }

  variables {
    name        = "prometheus_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Prometheus connector ID"
  }

  variables {
    name        = "ca_secret"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "CA certificate secret"
  }

  variables {
    name        = "client_cert_secret"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Client certificate secret"
  }

  variables {
    name        = "client_key_secret"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Client key secret"
  }

  tags = ["terraform", "apm", "prometheus", "tls", "secure"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 3: Datadog APM Probe - With Query
#############################################
resource "harness_chaos_probe_template" "apm_datadog_query" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-datadog-query"
  name        = "APM Datadog - Query Based"
  description = "Datadog APM probe with metric query"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Datadog"

    comparator {
      type     = "float"
      criteria = "<="
      value    = "95"
    }

    datadog_inputs {
      connector_id   = "<+input>"
      query          = "avg:system.cpu.user{*}"
      duration_in_min = 5
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    stop_on_failure  = true
    verbosity        = "info"
  }

  variables {
    name        = "datadog_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Datadog connector ID"
  }

  variables {
    name        = "cpu_threshold"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "CPU usage threshold percentage"
  }

  tags = ["terraform", "apm", "datadog", "query", "cpu-monitoring"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 4: Datadog APM Probe - Synthetics Test
#############################################
resource "harness_chaos_probe_template" "apm_datadog_synthetics" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-datadog-synthetics"
  name        = "APM Datadog - Synthetics Test"
  description = "Datadog APM probe with Synthetics test configuration"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Datadog"

    comparator {
      type     = "int"
      criteria = "=="
      value    = "0"
    }

    datadog_inputs {
      connector_id    = "<+input>"
      duration_in_min = 10

      synthetics_test {
        public_id = "<+input>"
        test_type = "api"
      }
    }
  }

  run_properties {
    timeout          = "60s"
    interval         = "20s"
    polling_interval = "5s"
    initial_delay    = "10s"
    stop_on_failure  = false
    verbosity        = "debug"
    attempt          = 3
    retry            = 2
  }

  variables {
    name        = "datadog_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Datadog connector ID"
  }

  variables {
    name        = "synthetics_test_id"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Datadog Synthetics test public ID"
  }

  tags = ["terraform", "apm", "datadog", "synthetics", "api-test"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 5: Dynatrace APM Probe - With Metrics
#############################################
resource "harness_chaos_probe_template" "apm_dynatrace_metrics" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-dynatrace-metrics"
  name        = "APM Dynatrace - Metrics Based"
  description = "Dynatrace APM probe with entity and metrics selectors"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Dynatrace"

    comparator {
      type     = "float"
      criteria = "<="
      value    = "500"
    }

    dynatrace_inputs {
      connector_id    = "<+input>"
      duration_in_min = 15

      metrics {
        entity_selector  = "type(SERVICE),tag(environment:production)"
        metrics_selector = "builtin:service.response.time:avg"
      }
    }
  }

  run_properties {
    timeout          = "40s"
    interval         = "15s"
    polling_interval = "3s"
    stop_on_failure  = true
    verbosity        = "info"
    attempt          = 5
    retry            = 3
  }

  variables {
    name        = "dynatrace_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Dynatrace connector ID"
  }

  variables {
    name        = "response_time_threshold"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Response time threshold in milliseconds"
  }

  tags = ["terraform", "apm", "dynatrace", "metrics", "response-time"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 6: AppDynamics APM Probe - With Metrics
#############################################
resource "harness_chaos_probe_template" "apm_appdynamics_metrics" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-appdynamics-metrics"
  name        = "APM AppDynamics - Metrics Based"
  description = "AppDynamics APM probe with application metrics"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "AppDynamics"

    comparator {
      type     = "float"
      criteria = "<"
      value    = "1000"
    }

    app_dynamics_inputs {
      connector_id = "<+input>"

      appd_metrics {
        application_name   = "<+input>"
        metrics_full_path  = "Application Infrastructure Performance|*|Individual Nodes|*|Agent|*|Availability"
        duration_in_min    = 10
      }
    }
  }

  run_properties {
    timeout          = "35s"
    interval         = "12s"
    polling_interval = "3s"
    stop_on_failure  = false
    verbosity        = "debug"
    attempt          = 4
    retry            = 2
  }

  variables {
    name        = "appdynamics_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "AppDynamics connector ID"
  }

  variables {
    name        = "application_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "AppDynamics application name"
  }

  variables {
    name        = "availability_threshold"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Availability threshold"
  }

  tags = ["terraform", "apm", "appdynamics", "metrics", "availability"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 7: NewRelic APM Probe - With Metric Query
#############################################
resource "harness_chaos_probe_template" "apm_newrelic_query" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-newrelic-query"
  name        = "APM NewRelic - NRQL Query"
  description = "NewRelic APM probe with NRQL query"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "NewRelic"

    comparator {
      type     = "float"
      criteria = "<="
      value    = "200"
    }

    new_relic_inputs {
      connector_id = "<+input>"

      new_relic_metric {
        query        = "SELECT average(duration) FROM Transaction WHERE appName = 'MyApp'"
        query_metric = "average.duration"
      }
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    stop_on_failure  = true
    verbosity        = "info"
    attempt          = 5
    retry            = 3
  }

  variables {
    name        = "newrelic_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "NewRelic connector ID"
  }

  variables {
    name        = "duration_threshold"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Transaction duration threshold in ms"
  }

  tags = ["terraform", "apm", "newrelic", "nrql", "transaction-monitoring"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 8: Splunk Observability APM Probe - With Metrics
#############################################
resource "harness_chaos_probe_template" "apm_splunk_metrics" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-splunk-metrics"
  name        = "APM Splunk Observability - Metrics"
  description = "Splunk Observability APM probe with metrics query"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "SplunkObservability"

    comparator {
      type     = "float"
      criteria = "<"
      value    = "85"
    }

    splunk_observability_inputs {
      connector_id = "<+input>"

      splunk_observability_metrics {
        query          = "data('cpu.utilization').mean()"
        duration_in_min = 5
      }
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    stop_on_failure  = false
    verbosity        = "info"
    attempt          = 4
    retry            = 2
  }

  variables {
    name        = "splunk_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Splunk Observability connector ID"
  }

  variables {
    name        = "cpu_threshold"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "CPU utilization threshold percentage"
  }

  tags = ["terraform", "apm", "splunk", "observability", "cpu-monitoring"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 9: GCP Cloud Monitoring APM Probe
#############################################
resource "harness_chaos_probe_template" "apm_gcp_monitoring" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-gcp-monitoring"
  name        = "APM GCP Cloud Monitoring"
  description = "GCP Cloud Monitoring APM probe"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "GCPCloudMonitoring"

    comparator {
      type     = "float"
      criteria = "<="
      value    = "90"
    }

    gcp_cloud_monitoring_inputs {
      project_id         = "<+input>"
      query              = "fetch gce_instance | metric 'compute.googleapis.com/instance/cpu/utilization' | group_by 1m, [value_utilization_mean: mean(value.utilization)] | every 1m"
      service_account_key = "<+input>"
    }
  }

  run_properties {
    timeout          = "45s"
    interval         = "15s"
    polling_interval = "3s"
    initial_delay    = "5s"
    stop_on_failure  = true
    verbosity        = "debug"
    attempt          = 5
    retry            = 3
  }

  variables {
    name        = "gcp_project_id"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "GCP project ID"
  }

  variables {
    name        = "service_account_key"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "GCP service account key (JSON)"
  }

  variables {
    name        = "cpu_threshold"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "CPU utilization threshold percentage"
  }

  tags = ["terraform", "apm", "gcp", "cloud-monitoring", "cpu-monitoring"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 10: Prometheus APM Probe - Complex Query with Runtime Inputs
#############################################
resource "harness_chaos_probe_template" "apm_prometheus_complex" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-prometheus-complex"
  name        = "APM Prometheus - Complex Query"
  description = "Prometheus APM probe with complex PromQL query and runtime inputs"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Prometheus"

    comparator {
      type     = "float"
      criteria = ">="
      value    = "<+input>"
    }

    prometheus_inputs {
      connector_id = "<+input>"
      query        = "sum(rate(http_requests_total{job='<+input>',status=~'2..'}[5m])) by (instance)"
    }
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "<+input>"
    polling_interval = "2s"
    initial_delay    = "5s"
    stop_on_failure  = false
    verbosity        = "trace"
    attempt          = 10
    retry            = 5
  }

  variables {
    name        = "prometheus_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Prometheus connector ID"
  }

  variables {
    name        = "job_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Job name for Prometheus query"
  }

  variables {
    name        = "success_rate_threshold"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Minimum success rate threshold"
  }

  variables {
    name        = "timeout_duration"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Probe timeout duration"
  }

  variables {
    name        = "interval_duration"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Probe interval duration"
  }

  tags = ["terraform", "apm", "prometheus", "complex", "runtime-inputs", "success-rate"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 11: Datadog APM Probe - Full Runtime Inputs
#############################################
resource "harness_chaos_probe_template" "apm_datadog_full_runtime" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-datadog-full-runtime"
  name        = "APM Datadog - Full Runtime Inputs"
  description = "Datadog APM probe with all fields as runtime inputs"
  type        = "apmProbe"

  infrastructure_type = "<+input>"

  apm_probe {
    apm_type = "Datadog"

    comparator {
      type     = "<+input>"
      criteria = "<+input>"
      value    = "<+input>"
    }

    datadog_inputs {
      connector_id    = "<+input>"
      query           = "<+input>"
      duration_in_min = 5

      synthetics_test {
        public_id = "<+input>"
        test_type = "<+input>"
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
    attempt          = 5
    retry            = 3
  }

  variables {
    name        = "datadog_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Datadog connector ID"
  }

  variables {
    name        = "query_string"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Datadog query string"
  }

  variables {
    name        = "synthetics_id"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Synthetics test public ID"
  }

  variables {
    name        = "test_type"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Synthetics test type (api/browser)"
  }

  tags = ["terraform", "apm", "datadog", "full-runtime", "advanced"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 12: Dynatrace APM Probe - Runtime Inputs
#############################################
resource "harness_chaos_probe_template" "apm_dynatrace_runtime" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-dynatrace-runtime"
  name        = "APM Dynatrace - Runtime Inputs"
  description = "Dynatrace APM probe with runtime input support"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Dynatrace"

    comparator {
      type     = "float"
      criteria = "<+input>"
      value    = "<+input>"
    }

    dynatrace_inputs {
      connector_id    = "<+input>"
      duration_in_min = 10

      metrics {
        entity_selector  = "<+input>"
        metrics_selector = "<+input>"
      }
    }
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "<+input>"
    polling_interval = "3s"
    stop_on_failure  = false
    verbosity        = "info"
  }

  variables {
    name        = "dynatrace_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Dynatrace connector ID"
  }

  variables {
    name        = "entity_selector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Dynatrace entity selector"
  }

  variables {
    name        = "metrics_selector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Dynatrace metrics selector"
  }

  tags = ["terraform", "apm", "dynatrace", "runtime-inputs"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 13: AppDynamics APM Probe - Runtime Inputs
#############################################
resource "harness_chaos_probe_template" "apm_appdynamics_runtime" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-appdynamics-runtime"
  name        = "APM AppDynamics - Runtime Inputs"
  description = "AppDynamics APM probe with runtime input support"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "AppDynamics"

    comparator {
      type     = "<+input>"
      criteria = "<+input>"
      value    = "<+input>"
    }

    app_dynamics_inputs {
      connector_id = "<+input>"

      appd_metrics {
        application_name  = "<+input>"
        metrics_full_path = "<+input>"
        duration_in_min   = 5
      }
    }
  }

  run_properties {
    timeout          = "<+input>"
    interval         = "15s"
    polling_interval = "3s"
    stop_on_failure  = true
    verbosity        = "<+input>"
  }

  variables {
    name        = "appdynamics_connector"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "AppDynamics connector ID"
  }

  variables {
    name        = "app_name"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "AppDynamics application name"
  }

  variables {
    name        = "metrics_path"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Full path to AppDynamics metric"
  }

  tags = ["terraform", "apm", "appdynamics", "runtime-inputs"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# REAL CONNECTOR TESTS
# These tests use actual connector variables for integration testing
#############################################

#############################################
# Test 14: Prometheus APM Probe - Real Connector
#############################################
resource "harness_chaos_probe_template" "apm_prometheus_real_connector" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests && var.prometheus_connector_id != "" ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-prometheus-real"
  name        = "APM Prometheus - Real Connector"
  description = "Prometheus APM probe with real connector for integration testing"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Prometheus"

    comparator {
      type     = "float"
      criteria = "<="
      value    = var.prometheus_threshold
    }

    prometheus_inputs {
      connector_id = var.prometheus_connector_id
      query        = var.prometheus_query
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    stop_on_failure  = false
    verbosity        = "info"
    attempt          = 3
    retry            = 2
  }

  tags = ["terraform", "apm", "prometheus", "real-connector", "integration"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 15: Datadog APM Probe - Real Connector
#############################################
resource "harness_chaos_probe_template" "apm_datadog_real_connector" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests && var.datadog_connector_id != "" ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-datadog-real"
  name        = "APM Datadog - Real Connector"
  description = "Datadog APM probe with real connector for integration testing"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Datadog"

    comparator {
      type     = "float"
      criteria = "<="
      value    = var.datadog_threshold
    }

    datadog_inputs {
      connector_id    = var.datadog_connector_id
      query           = var.datadog_query
      duration_in_min = 5
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    stop_on_failure  = true
    verbosity        = "info"
    attempt          = 3
    retry            = 2
  }

  tags = ["terraform", "apm", "datadog", "real-connector", "integration"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 16: Dynatrace APM Probe - Real Connector
#############################################
resource "harness_chaos_probe_template" "apm_dynatrace_real_connector" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests && var.dynatrace_connector_id != "" ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-dynatrace-real"
  name        = "APM Dynatrace - Real Connector"
  description = "Dynatrace APM probe with real connector for integration testing"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "Dynatrace"

    comparator {
      type     = "float"
      criteria = "<="
      value    = var.dynatrace_threshold
    }

    dynatrace_inputs {
      connector_id    = var.dynatrace_connector_id
      duration_in_min = 10

      metrics {
        entity_selector  = var.dynatrace_entity_selector
        metrics_selector = var.dynatrace_metrics_selector
      }
    }
  }

  run_properties {
    timeout          = "40s"
    interval         = "15s"
    polling_interval = "3s"
    stop_on_failure  = true
    verbosity        = "info"
    attempt          = 3
    retry            = 2
  }

  tags = ["terraform", "apm", "dynatrace", "real-connector", "integration"]

  lifecycle {
    ignore_changes = [tags]
  }
}

#############################################
# Test 17: NewRelic APM Probe - Real Connector
#############################################
resource "harness_chaos_probe_template" "apm_newrelic_real_connector" {
  depends_on = [
    harness_chaos_hub_v2.project_level
  ]

  count = var.enable_probe_template_tests && var.newrelic_connector_id != "" ? 1 : 0

  org_id       = local.org_id
  project_id   = local.project_id
  hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

  identity    = "apm-newrelic-real"
  name        = "APM NewRelic - Real Connector"
  description = "NewRelic APM probe with real connector for integration testing"
  type        = "apmProbe"

  infrastructure_type = "Kubernetes"

  apm_probe {
    apm_type = "NewRelic"

    comparator {
      type     = "float"
      criteria = "<="
      value    = var.newrelic_threshold
    }

    new_relic_inputs {
      connector_id = var.newrelic_connector_id

      new_relic_metric {
        query        = var.newrelic_query
        query_metric = var.newrelic_query_metric
      }
    }
  }

  run_properties {
    timeout          = "30s"
    interval         = "10s"
    polling_interval = "2s"
    stop_on_failure  = true
    verbosity        = "info"
    attempt          = 3
    retry            = 2
  }

  tags = ["terraform", "apm", "newrelic", "real-connector", "integration"]

  lifecycle {
    ignore_changes = [tags]
  }
}
