# ============================================================================
# Step 16: Security Governance V3 (REST API) - ChaosGuard
# ============================================================================
# Mirrors the V1 (GraphQL) security governance coverage using the new V3
# REST-backed resources:
#   - harness_chaos_security_governance_condition_v3
#   - harness_chaos_security_governance_rule_v3
#   - data.harness_chaos_security_governance_condition_v3
#   - data.harness_chaos_security_governance_rule_v3
#
# The primary goal is to validate that namespace_labels (native map) no longer
# drifts on plan, across all 8 scenarios, plus rule wiring and data sources.
# All resources are gated on the dedicated `local.create_security_governance_v3`
# flag (var.enable_security_governance_v3), so V3 can be toggled independently
# of the V1 (GraphQL) security governance resources.

# ----------------------------------------------------------------------------
# Test 1: EQUAL_TO with Namespace Labels
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "ns_labels_equal_to" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-ns-labels-equal-to"
  description = "V3: Block experiments in production namespaces (EQUAL_TO test)"
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
      operator = "EQUAL_TO"

      workloads {
        kind      = "*"
        label     = "*"
        namespace = ""

        namespace_labels = {
          "environment" = "production"
        }
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

# ----------------------------------------------------------------------------
# Test 2: NOT_EQUAL_TO with Namespace Labels (CRITICAL drift scenario)
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "ns_labels_not_equal_to" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-ns-labels-not-equal-to"
  description = "V3: Block experiments in non-production namespaces (NOT_EQUAL_TO test)"
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
      operator = "NOT_EQUAL_TO"

      workloads {
        kind      = "*"
        label     = "*"
        namespace = ""

        namespace_labels = {
          "environment" = "production"
        }
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

# ----------------------------------------------------------------------------
# Test 3: Multiple Namespace Labels (AND logic)
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "ns_labels_multiple" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-ns-labels-multiple"
  description = "V3: Block experiments in namespaces with multiple labels (AND logic test)"
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
      operator = "EQUAL_TO"

      workloads {
        kind      = "*"
        label     = "*"
        namespace = ""

        namespace_labels = {
          "environment" = "production"
          "team"        = "platform"
          "managed-by"  = "terraform"
        }
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

# ----------------------------------------------------------------------------
# Test 4: Special Characters in Namespace Labels
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "ns_labels_special_chars" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-ns-labels-special-chars"
  description = "V3: Test special characters in namespace labels"
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
      operator = "EQUAL_TO"

      workloads {
        kind      = "deployment"
        namespace = "default"

        namespace_labels = {
          "kubernetes.io/metadata.name"  = "app"
          "app.kubernetes.io/name"       = "nginx"
          "app.kubernetes.io/version"    = "v1.2.3-beta+build.123"
          "app.kubernetes.io/managed-by" = "terraform"
        }
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

# ----------------------------------------------------------------------------
# Test 5: Combined Criteria (Namespace Labels + Kind + Label)
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "ns_labels_combined" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-ns-labels-combined"
  description = "V3: Test namespace labels combined with other criteria"
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
      operator = "EQUAL_TO"

      workloads {
        kind      = "deployment"
        label     = "app=nginx"
        namespace = "production"

        namespace_labels = {
          "environment" = "production"
        }
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

# ----------------------------------------------------------------------------
# Test 6: Update Test - condition initially without namespace labels
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "ns_labels_update" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-ns-labels-update"
  description = "V3: Test updating condition to add namespace labels"
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
      operator = "EQUAL_TO"

      workloads {
        kind      = "deployment"
        namespace = "default"

        # Initially no namespace labels; flip the block below to test updates.
        # namespace_labels = {
        #   "environment" = "staging"
        # }
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

# ----------------------------------------------------------------------------
# Test 7: Backward Compatibility - No Namespace Labels
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "backward_compat_no_labels" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-backward-compat-no-labels"
  description = "V3: Backward compatibility test - no namespace labels"
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
      operator = "EQUAL_TO"

      workloads {
        kind      = "deployment"
        label     = "app=nginx"
        namespace = "default"
        # NO namespace_labels - old behavior
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

# ----------------------------------------------------------------------------
# Test 8: Backward Compatibility - Empty Namespace Labels
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "backward_compat_empty_labels" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-backward-compat-empty-labels"
  description = "V3: Backward compatibility test - empty namespace labels"
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
      operator = "EQUAL_TO"

      workloads {
        kind      = "deployment"
        namespace = "default"

        namespace_labels = {}
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

# ----------------------------------------------------------------------------
# Rule (V3) - wires the EQUAL_TO condition into an active rule
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_rule_v3" "this" {
  count = local.create_security_governance_v3 ? 1 : 0

  depends_on = [
    harness_chaos_security_governance_condition_v3.ns_labels_equal_to,
  ]

  name        = "test-v3-security-governance-rule"
  description = "V3: Rule wiring the namespace-labels EQUAL_TO condition"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  is_enabled  = true
  tags        = ["managed-by=terraform", "api=v3"]

  condition_ids  = [harness_chaos_security_governance_condition_v3.ns_labels_equal_to[0].id]
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
# Data sources (V3) - validate lookup by identity and by name
# ----------------------------------------------------------------------------
data "harness_chaos_security_governance_condition_v3" "by_identity" {
  count = local.create_security_governance_v3 ? 1 : 0

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  identity   = harness_chaos_security_governance_condition_v3.ns_labels_equal_to[0].id
}

data "harness_chaos_security_governance_rule_v3" "by_name" {
  count = local.create_security_governance_v3 ? 1 : 0

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  name       = "test-v3-security-governance-rule"

  depends_on = [harness_chaos_security_governance_rule_v3.this]
}

# ----------------------------------------------------------------------------
# Dedicated NOT_EQUAL_TO test - namespace labels round-trip (drift guard)
#
# NOT_EQUAL_TO + namespace_labels is the critical drift scenario: the map and
# operator must read back exactly as configured. This reads the Test-2
# condition (ns_labels_not_equal_to) back via the data source and fails the
# apply if either the operator or the label value does not round-trip.
# ----------------------------------------------------------------------------
data "harness_chaos_security_governance_condition_v3" "not_equal_to_by_identity" {
  count = local.create_security_governance_v3 ? 1 : 0

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  identity   = harness_chaos_security_governance_condition_v3.ns_labels_not_equal_to[0].id
}

resource "null_resource" "v3_not_equal_to_validation" {
  count = local.create_security_governance_v3 ? 1 : 0

  triggers = {
    operator        = try(data.harness_chaos_security_governance_condition_v3.not_equal_to_by_identity[0].k8s_spec[0].application_spec[0].operator, "")
    namespace_label = try(data.harness_chaos_security_governance_condition_v3.not_equal_to_by_identity[0].k8s_spec[0].application_spec[0].workloads[0].namespace_labels["environment"], "")
  }

  lifecycle {
    precondition {
      condition     = try(data.harness_chaos_security_governance_condition_v3.not_equal_to_by_identity[0].k8s_spec[0].application_spec[0].operator, "") == "NOT_EQUAL_TO"
      error_message = "V3 NOT_EQUAL_TO drift: application_spec.operator did not round-trip as NOT_EQUAL_TO."
    }

    precondition {
      condition     = try(data.harness_chaos_security_governance_condition_v3.not_equal_to_by_identity[0].k8s_spec[0].application_spec[0].workloads[0].namespace_labels["environment"], "") == "production"
      error_message = "V3 NOT_EQUAL_TO drift: namespace_labels[\"environment\"] did not round-trip as \"production\"."
    }
  }
}

# ----------------------------------------------------------------------------
# Outputs for verification
# ----------------------------------------------------------------------------
output "v3_namespace_labels_condition_ids" {
  description = "IDs of V3 namespace labels test conditions"
  value = {
    equal_to              = try(harness_chaos_security_governance_condition_v3.ns_labels_equal_to[0].id, "")
    not_equal_to          = try(harness_chaos_security_governance_condition_v3.ns_labels_not_equal_to[0].id, "")
    multiple              = try(harness_chaos_security_governance_condition_v3.ns_labels_multiple[0].id, "")
    special_chars         = try(harness_chaos_security_governance_condition_v3.ns_labels_special_chars[0].id, "")
    combined              = try(harness_chaos_security_governance_condition_v3.ns_labels_combined[0].id, "")
    update                = try(harness_chaos_security_governance_condition_v3.ns_labels_update[0].id, "")
    backward_compat_none  = try(harness_chaos_security_governance_condition_v3.backward_compat_no_labels[0].id, "")
    backward_compat_empty = try(harness_chaos_security_governance_condition_v3.backward_compat_empty_labels[0].id, "")
  }
}

output "v3_security_governance_rule_id" {
  description = "ID of the V3 security governance rule"
  value       = try(harness_chaos_security_governance_rule_v3.this[0].id, "")
}

output "v3_data_source_lookups" {
  description = "V3 data source lookup verification (by identity and by name)"
  value = {
    condition_by_identity_name = try(data.harness_chaos_security_governance_condition_v3.by_identity[0].name, "")
    rule_by_name_id            = try(data.harness_chaos_security_governance_rule_v3.by_name[0].id, "")
  }
}

output "v3_not_equal_to_roundtrip" {
  description = "Read-back of the NOT_EQUAL_TO namespace-labels condition (drift verification)"
  value = {
    operator         = try(data.harness_chaos_security_governance_condition_v3.not_equal_to_by_identity[0].k8s_spec[0].application_spec[0].operator, "")
    namespace_labels = try(data.harness_chaos_security_governance_condition_v3.not_equal_to_by_identity[0].k8s_spec[0].application_spec[0].workloads[0].namespace_labels, {})
  }
}

# ============================================================================
# Extended V3 scenarios (opt-in: enable_security_governance_v3_extended)
# ============================================================================
# These broaden V3 coverage beyond the KubernetesV2 / k8s_spec / FAULT path:
#   - machine_spec (Linux infra_type)
#   - fault_type = FAULT_GROUP
#   - time windows with recurrence (Weekly, Daily) and end_time
#
# Gated off by default because machine_spec references Linux infra IDs that may
# not exist in every account. Set enable_security_governance_v3_extended=true
# (with a real Linux chaos infra) to run them.

# ----------------------------------------------------------------------------
# Extended 1: machine_spec (Linux) condition
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "machine_linux" {
  count = local.create_security_governance_v3_extended ? 1 : 0

  name        = "test-v3-machine-linux"
  description = "V3: Linux machine_spec condition (extended coverage)"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  infra_type  = "Linux"

  fault_spec {
    operator = "EQUAL_TO"
    faults {
      fault_type = "FAULT"
      name       = "*"
    }
  }

  machine_spec {
    infra_spec {
      operator  = "EQUAL_TO"
      infra_ids = var.security_governance_v3_linux_infra_ids
    }
  }

  lifecycle {
    ignore_changes = [name]
  }
}

# ----------------------------------------------------------------------------
# Extended 2: FAULT_GROUP fault_spec condition (KubernetesV2)
# ----------------------------------------------------------------------------
resource "harness_chaos_security_governance_condition_v3" "fault_group" {
  count = local.create_security_governance_v3_extended ? 1 : 0

  depends_on = [
    harness_platform_environment.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = "test-v3-fault-group"
  description = "V3: FAULT_GROUP fault_spec (extended coverage)"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  infra_type  = "KubernetesV2"

  fault_spec {
    operator = "EQUAL_TO"
    faults {
      fault_type = "FAULT_GROUP"
      name       = "*"
    }
  }

  k8s_spec {
    infra_spec {
      operator  = "EQUAL_TO"
      infra_ids = ["${harness_platform_environment.this.id}/${try(harness_chaos_infrastructure_v2.this[0].id, "")}"]
    }

    application_spec {
      operator = "EQUAL_TO"
      workloads {
        kind      = "*"
        label     = "*"
        namespace = "default"
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

# ----------------------------------------------------------------------------
# Extended 3: Rule with recurring + end_time time windows
# ----------------------------------------------------------------------------
# Window 1: Weekly recurrence, duration-based.
# Window 2: Daily recurrence, end_time-based (mutually exclusive with duration).
#           Monthly is intentionally avoided here because the backend does not
#           persist the Monthly `value`, which would cause a perpetual diff.
resource "harness_chaos_security_governance_rule_v3" "extended" {
  count = local.create_security_governance_v3_extended ? 1 : 0

  depends_on = [
    harness_chaos_security_governance_condition_v3.fault_group,
  ]

  name        = "test-v3-rule-extended"
  description = "V3: Rule with Weekly/Daily recurrence and end_time windows"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  is_enabled  = true
  tags        = ["managed-by=terraform", "api=v3", "extended"]

  condition_ids  = [harness_chaos_security_governance_condition_v3.fault_group[0].id]
  user_group_ids = var.security_governance_rule_user_group_ids

  time_windows {
    time_zone  = "UTC"
    start_time = 1756616940000
    duration   = "1h"

    recurrence {
      type  = "Weekly"
      until = -1
    }
  }

  time_windows {
    time_zone  = "America/New_York"
    start_time = 1756616940000
    end_time   = 1756620540000 # start + 1h; mutually exclusive with duration

    recurrence {
      # Monthly is intentionally avoided: the backend validates the Monthly
      # value (1-11) but does not persist it (chaosguardrules/service.go rebuilds
      # RecurrenceSpec without Value), so it reads back as 0 and causes a
      # perpetual "value = 0 -> N" diff. Daily takes no value and round-trips
      # cleanly.
      type  = "Daily"
      until = -1
    }
  }

  lifecycle {
    ignore_changes = [name]
  }
}

output "v3_extended_ids" {
  description = "IDs of the extended V3 scenario resources (empty unless enabled)"
  value = local.create_security_governance_v3_extended ? {
    machine_linux = try(harness_chaos_security_governance_condition_v3.machine_linux[0].id, "")
    fault_group   = try(harness_chaos_security_governance_condition_v3.fault_group[0].id, "")
    rule_extended = try(harness_chaos_security_governance_rule_v3.extended[0].id, "")
  } : null
}
