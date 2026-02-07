# Security Governance Resources Comparison

## Summary: ✅ MATCHES (with minor differences)

The security governance resources in e2e-test closely match main.tf with only minor intentional differences.

## 1. Security Governance Condition

### Main.tf (Dynamic/Parameterized)
```hcl
resource "harness_chaos_security_governance_condition" "this" {
  depends_on = [
    harness_platform_environment.this,
    harness_platform_infrastructure.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = var.security_governance_condition_name
  description = "Condition to block destructive experiments"
  org_id      = local.org_id
  project_id  = local.project_id

  infra_type = var.security_governance_condition_infra_type

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

  dynamic "k8s_spec" {
    for_each = var.security_governance_condition_infra_type == "KubernetesV2" ? [1] : []
    content {
      infra_spec {
        operator  = var.security_governance_condition_infra_operator
        infra_ids = ["${harness_platform_environment.this.id}/${harness_chaos_infrastructure_v2.this.id}"]
      }

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

      dynamic "chaos_service_account_spec" {
        for_each = var.security_governance_condition_service_account_spec != null ? [1] : []
        content {
          operator         = var.security_governance_condition_service_account_spec.operator
          service_accounts = var.security_governance_condition_service_account_spec.service_accounts
        }
      }
    }
  }

  dynamic "machine_spec" {
    for_each = contains(["Windows", "Linux"], var.security_governance_condition_infra_type) ? [1] : []
    content {
      infra_spec {
        operator  = var.security_governance_condition_infra_operator
        infra_ids = var.security_governance_condition_infra_ids
      }
    }
  }

  lifecycle {
    ignore_changes = [name]
  }

  tags = [
    for k, v in merge(
      local.common_tags,
      {
        "platform" = lower(var.security_governance_condition_infra_type)
      }
    ) : "${k}=${v}"
  ]
}
```

### E2E Test (Hardcoded/Specific)
```hcl
resource "harness_chaos_security_governance_condition" "this" {
  depends_on = [
    harness_platform_environment.this,
    harness_platform_infrastructure.this,
    harness_chaos_infrastructure_v2.this
  ]

  name        = var.security_governance_condition_name
  description = "Security condition to control chaos experiments"
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id

  infra_type = "KubernetesV2"

  fault_spec {
    operator = "IN"

    faults {
      fault_type = "KubernetesV2"
      name       = "pod-delete"
    }

    faults {
      fault_type = "KubernetesV2"
      name       = "container-kill"
    }

    faults {
      fault_type = "KubernetesV2"
      name       = "pod-network-loss"
    }
  }

  k8s_spec {
    infra_spec {
      operator  = "IN"
      infra_ids = ["${harness_platform_environment.this.id}/${harness_chaos_infrastructure_v2.this.id}"]
    }

    application_spec {
      operator = "IN"

      workloads {
        namespace = var.namespace
        kind      = "deployment"
      }

      workloads {
        namespace = var.namespace
        kind      = "statefulset"
      }
    }

    chaos_service_account_spec {
      operator         = "IN"
      service_accounts = [var.chaos_service_account]
    }
  }

  tags = [
    for k, v in merge(
      local.common_tags,
      {
        "platform" = "kubernetes"
      }
    ) : "${k}=${v}"
  ]

  lifecycle {
    ignore_changes = [name]
  }
}
```

### Differences: ✅ INTENTIONAL

| Aspect | Main.tf | E2E Test | Status |
|--------|---------|----------|--------|
| **Approach** | Dynamic (variables) | Hardcoded | ✅ OK |
| **infra_type** | Variable | "KubernetesV2" | ✅ OK |
| **fault_spec** | Dynamic loop | Static 3 faults | ✅ OK |
| **k8s_spec** | Conditional dynamic | Always present | ✅ OK |
| **application_spec** | Conditional dynamic | Always present | ✅ OK |
| **chaos_service_account_spec** | Conditional dynamic | Always present | ✅ OK |
| **machine_spec** | Conditional dynamic | Not present | ✅ OK (K8s only) |
| **Tags platform value** | `lower(var...)` | "kubernetes" | ✅ OK |

**Rationale**: Main.tf is designed for flexibility (supports K8s, Windows, Linux), while e2e-test is focused on a specific K8s scenario.

## 2. Security Governance Rule

### Main.tf
```hcl
resource "harness_chaos_security_governance_rule" "this" {
  depends_on = [
    harness_chaos_security_governance_condition.this
  ]

  name        = var.security_governance_rule_name
  description = var.security_governance_rule_description
  org_id      = local.org_id
  project_id  = local.project_id
  is_enabled  = var.security_governance_rule_is_enabled

  condition_ids  = [harness_chaos_security_governance_condition.this.id]
  user_group_ids = var.security_governance_rule_user_group_ids

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

  lifecycle {
    ignore_changes = [name]
  }

  tags = [
    for k, v in merge(
      local.common_tags,
      {
        "platform" = lower(var.security_governance_condition_infra_type)
      }
    ) : "${k}=${v}"
  ]
}
```

### E2E Test
```hcl
resource "harness_chaos_security_governance_rule" "this" {
  depends_on = [
    harness_chaos_security_governance_condition.this
  ]

  name        = var.security_governance_rule_name
  description = var.security_governance_rule_description
  org_id      = harness_platform_organization.this.id
  project_id  = harness_platform_project.this.id
  is_enabled  = var.security_governance_rule_is_enabled

  condition_ids  = [harness_chaos_security_governance_condition.this.id]
  user_group_ids = var.security_governance_rule_user_group_ids

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

  tags = [
    for k, v in merge(
      local.common_tags,
      {
        "platform" = "kubernetes"
      }
    ) : "${k}=${v}"
  ]

  lifecycle {
    ignore_changes = [name]
  }
}
```

### Differences: ✅ MINOR

| Aspect | Main.tf | E2E Test | Status |
|--------|---------|----------|--------|
| **Structure** | Identical | Identical | ✅ Match |
| **Fields** | All present | All present | ✅ Match |
| **time_windows** | Dynamic | Dynamic | ✅ Match |
| **Tags platform value** | `lower(var...)` | "kubernetes" | ✅ OK |
| **org_id/project_id** | `local.org_id` | Direct reference | ✅ OK |

**Only difference**: Tags platform value (hardcoded vs variable) - intentional and acceptable.

## Field-by-Field Comparison

### Security Governance Condition

| Field | Main.tf | E2E Test | Match |
|-------|---------|----------|-------|
| `name` | ✅ Variable | ✅ Variable | ✅ |
| `description` | ✅ Hardcoded | ✅ Hardcoded | ✅ |
| `org_id` | ✅ local.org_id | ✅ Direct ref | ✅ |
| `project_id` | ✅ local.project_id | ✅ Direct ref | ✅ |
| `infra_type` | ✅ Variable | ✅ Hardcoded | ✅ |
| `fault_spec` | ✅ Dynamic | ✅ Static | ✅ |
| `fault_spec.operator` | ✅ Variable | ✅ Hardcoded | ✅ |
| `fault_spec.faults` | ✅ Dynamic loop | ✅ 3 static | ✅ |
| `k8s_spec` | ✅ Conditional | ✅ Always | ✅ |
| `k8s_spec.infra_spec` | ✅ Present | ✅ Present | ✅ |
| `k8s_spec.infra_spec.operator` | ✅ Variable | ✅ Hardcoded | ✅ |
| `k8s_spec.infra_spec.infra_ids` | ✅ Computed | ✅ Computed | ✅ |
| `k8s_spec.application_spec` | ✅ Conditional | ✅ Always | ✅ |
| `k8s_spec.application_spec.operator` | ✅ Variable | ✅ Hardcoded | ✅ |
| `k8s_spec.application_spec.workloads` | ✅ Dynamic | ✅ 2 static | ✅ |
| `k8s_spec.chaos_service_account_spec` | ✅ Conditional | ✅ Always | ✅ |
| `machine_spec` | ✅ Conditional | ❌ Not present | ✅ OK |
| `lifecycle.ignore_changes` | ✅ [name] | ✅ [name] | ✅ |
| `tags` | ✅ Merged | ✅ Merged | ✅ |

### Security Governance Rule

| Field | Main.tf | E2E Test | Match |
|-------|---------|----------|-------|
| `name` | ✅ Variable | ✅ Variable | ✅ |
| `description` | ✅ Variable | ✅ Variable | ✅ |
| `org_id` | ✅ local.org_id | ✅ Direct ref | ✅ |
| `project_id` | ✅ local.project_id | ✅ Direct ref | ✅ |
| `is_enabled` | ✅ Variable | ✅ Variable | ✅ |
| `condition_ids` | ✅ [condition.id] | ✅ [condition.id] | ✅ |
| `user_group_ids` | ✅ Variable | ✅ Variable | ✅ |
| `time_windows` | ✅ Dynamic | ✅ Dynamic | ✅ |
| `time_windows.time_zone` | ✅ Variable | ✅ Variable | ✅ |
| `time_windows.start_time` | ✅ Variable | ✅ Variable | ✅ |
| `time_windows.duration` | ✅ Variable | ✅ Variable | ✅ |
| `time_windows.recurrence` | ✅ Conditional | ✅ Conditional | ✅ |
| `time_windows.recurrence.type` | ✅ Variable | ✅ Variable | ✅ |
| `time_windows.recurrence.until` | ✅ Variable | ✅ Variable | ✅ |
| `lifecycle.ignore_changes` | ✅ [name] | ✅ [name] | ✅ |
| `tags` | ✅ Merged | ✅ Merged | ✅ |

## Variables Comparison

### Main.tf Variables (Comprehensive)
```hcl
# Condition variables
variable "security_governance_condition_name" { }
variable "security_governance_condition_infra_type" { }
variable "security_governance_condition_operator" { }
variable "security_governance_condition_faults" { type = list(object) }
variable "security_governance_condition_infra_operator" { }
variable "security_governance_condition_infra_ids" { }
variable "security_governance_condition_application_spec" { type = object }
variable "security_governance_condition_service_account_spec" { type = object }

# Rule variables
variable "security_governance_rule_name" { }
variable "security_governance_rule_description" { }
variable "security_governance_rule_is_enabled" { }
variable "security_governance_rule_user_group_ids" { }
variable "security_governance_rule_time_windows" { type = list(object) }
```

### E2E Test Variables (Focused)
```hcl
# Condition variables
variable "security_governance_condition_name" {
  description = "Security governance condition name"
  type        = string
  default     = "E2E Security Condition"
}

# Rule variables
variable "security_governance_rule_name" {
  description = "Security governance rule name"
  type        = string
  default     = "E2E Security Rule"
}

variable "security_governance_rule_description" {
  description = "Security governance rule description"
  type        = string
  default     = "E2E test security governance rule"
}

variable "security_governance_rule_is_enabled" {
  description = "Whether the security governance rule is enabled"
  type        = bool
  default     = true
}

variable "security_governance_rule_user_group_ids" {
  description = "User group IDs for the security governance rule"
  type        = list(string)
  default     = []
}

variable "security_governance_rule_time_windows" {
  description = "Time windows for the security governance rule"
  type = list(object({
    time_zone  = string
    start_time = string
    duration   = string
    recurrence = optional(object({
      type  = string
      until = string
    }))
  }))
  default = []
}
```

**Status**: ✅ E2E test has all necessary variables

## Key Patterns

### Both Use:
1. ✅ **lifecycle.ignore_changes = [name]** - Prevents drift on name field
2. ✅ **Tags merging** - Combines common_tags with resource-specific tags
3. ✅ **Dynamic time_windows** - Supports optional time window configuration
4. ✅ **Nested recurrence** - Conditional recurrence block
5. ✅ **Computed infra_ids** - Uses environment_id/infra_id format

### Main.tf Advantages:
- ✅ **Flexible** - Supports K8s, Windows, Linux via variables
- ✅ **Parameterized** - All values configurable
- ✅ **Reusable** - Can be used in different scenarios

### E2E Test Advantages:
- ✅ **Simple** - Hardcoded for specific K8s scenario
- ✅ **Clear** - Easy to understand what's being tested
- ✅ **Focused** - Tests specific fault types and workloads

## Conclusion

✅ **SECURITY GOVERNANCE RESOURCES MATCH**

The security governance resources in e2e-test correctly match the patterns from main.tf:

1. ✅ **Condition**: Uses same structure, fields, and nested blocks
2. ✅ **Rule**: Identical structure and fields
3. ✅ **Differences**: Intentional (dynamic vs hardcoded) - both valid
4. ✅ **Variables**: E2E test has all necessary variables
5. ✅ **Patterns**: Both use lifecycle, tags, dynamic blocks correctly

### Status:
- ✅ Main.tf: Flexible, parameterized (working)
- ✅ E2E Test: Focused, hardcoded (matches main.tf patterns)
- ✅ No changes needed

### Recommendation:
✅ **No changes required** - E2E test security governance resources are correct and follow the same patterns as main.tf. The differences (dynamic vs hardcoded) are intentional and appropriate for an e2e test scenario.
