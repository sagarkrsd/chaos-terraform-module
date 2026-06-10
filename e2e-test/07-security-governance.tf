# ============================================================================
# Step 10: Security Governance Rules and Conditions
# ============================================================================
# NOTE: Temporarily commented out due to GraphQL API "internal system error"
# This may require the security governance feature to be enabled in the account

# ----------------------------------------------------------------------------
# Security Governance Condition
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition" "this" {
  count = local.create_security_governance ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_platform_infrastructure.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = var.security_governance_condition_name
  description = "Condition to block destructive experiments"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id

  // Required fields - Set the appropriate infra_type based on your needs
  infra_type = var.security_governance_condition_infra_type

  // Fault specifications
  fault_spec {
    operator = var.security_governance_condition_operator

    dynamic "faults" {
      for_each = var.security_governance_condition_faults
      content {
        fault_type = faults.value.fault_type
        name       = faults.value.name
      }
    }
  }

  // Kubernetes specific specifications (only for KubernetesV2 infra_type)
  dynamic "k8s_spec" {
    for_each = var.security_governance_condition_infra_type == "KubernetesV2" ? [1] : []
    content {
      infra_spec {
        operator  = var.security_governance_condition_infra_operator
        infra_ids = ["${harness_platform_environment.this.id}/${try(harness_chaos_infrastructure_v2.this[0].id, "")}"]
      }

      // Application specification (optional)
      dynamic "application_spec" {
        for_each = var.security_governance_condition_application_spec != null ? [1] : []
        content {
          operator = var.security_governance_condition_application_spec.operator

          dynamic "workloads" {
            for_each = var.security_governance_condition_application_spec.workloads
            content {
              namespace = workloads.value.namespace
              kind      = workloads.value.kind
            }
          }
        }
      }

      // Chaos service account specification (optional)
      dynamic "chaos_service_account_spec" {
        for_each = var.security_governance_condition_service_account_spec != null ? [1] : []
        content {
          operator         = var.security_governance_condition_service_account_spec.operator
          service_accounts = var.security_governance_condition_service_account_spec.service_accounts
        }
      }
    }
  }

  // Machine specifications (for Windows/Linux infra_type)
  dynamic "machine_spec" {
    for_each = contains(["Windows", "Linux"], var.security_governance_condition_infra_type) ? [1] : []
    content {
      infra_spec {
        operator  = var.security_governance_condition_infra_operator
        infra_ids = var.security_governance_condition_infra_ids
      }
    }
  }

  // Lifecycle to handle name changes
  lifecycle {
    ignore_changes = [name]
  }

//   # Convert merged tags to list of strings format
//   tags = [
//     for k, v in merge(
//       local.common_tags,
//       {
//         "platform" = lower(var.security_governance_condition_infra_type)
//       }
//     ) : "${k}=${v}"
//   ]
}

# ----------------------------------------------------------------------------
# Security Governance Rule
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_rule" "this" {
  count = local.create_security_governance ? 1 : 0

  depends_on = [
    harness_chaos_security_governance_condition.this
  ]

  name        = var.security_governance_rule_name
  description = var.security_governance_rule_description
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  is_enabled  = var.security_governance_rule_is_enabled

  // Required fields
  condition_ids  = [local.security_governance_condition_id]
  user_group_ids = var.security_governance_rule_user_group_ids

  // Time window configuration
  dynamic "time_windows" {
    for_each = var.security_governance_rule_time_windows
    content {
      time_zone  = time_windows.value.time_zone
      start_time = time_windows.value.start_time
      duration   = time_windows.value.duration

      dynamic "recurrence" {
        for_each = time_windows.value.recurrence != null ? [time_windows.value.recurrence] : []
        content {
          type  = recurrence.value.type
          until = recurrence.value.until
        }
      }
    }
  }

  // Lifecycle to handle name changes
  lifecycle {
    ignore_changes = [name]
  }

//   # Convert merged tags to list of strings format
//   tags = [
//     for k, v in merge(
//       local.common_tags,
//       {
//         "platform" = lower(var.security_governance_condition_infra_type)
//       }
//     ) : "${k}=${v}"
//   ]
}
