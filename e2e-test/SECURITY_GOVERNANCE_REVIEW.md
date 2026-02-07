# Security Governance File Review

## File: 07-security-governance.tf

### Status: ❌ MISSING VARIABLES

The file uses variables from main.tf that are NOT defined in e2e-test/variables.tf

## Variables Used in File

### ✅ Defined Variables (6)
1. `var.security_governance_condition_name` ✅
2. `var.security_governance_rule_name` ✅
3. `var.security_governance_rule_description` ✅
4. `var.security_governance_rule_is_enabled` ✅
5. `var.security_governance_rule_user_group_ids` ✅
6. `var.security_governance_rule_time_windows` ✅

### ❌ Missing Variables (7)
1. `var.security_governance_condition_infra_type` ❌
2. `var.security_governance_condition_operator` ❌
3. `var.security_governance_condition_faults` ❌
4. `var.security_governance_condition_infra_operator` ❌
5. `var.security_governance_condition_application_spec` ❌
6. `var.security_governance_condition_service_account_spec` ❌
7. `var.security_governance_condition_infra_ids` ❌

## Problem

The file was copied from main.tf which uses a **dynamic, parameterized approach** with many variables. However, e2e-test should use a **simple, hardcoded approach** for testing.

## Solution Options

### Option 1: Add Missing Variables (Maintain Flexibility)

Add all missing variables to `variables.tf`:

```hcl
variable "security_governance_condition_infra_type" {
  description = "Infrastructure type for security governance"
  type        = string
  default     = "KubernetesV2"
}

variable "security_governance_condition_operator" {
  description = "Operator for fault spec"
  type        = string
  default     = "EQUAL_TO"
}

variable "security_governance_condition_faults" {
  description = "List of faults to govern"
  type = list(object({
    fault_type = string
    name       = string
  }))
  default = [
    {
      fault_type = "FAULT"
      name       = "pod-delete"
    },
    {
      fault_type = "FAULT"
      name       = "container-kill"
    },
    {
      fault_type = "FAULT"
      name       = "pod-network-loss"
    }
  ]
}

variable "security_governance_condition_infra_operator" {
  description = "Operator for infrastructure spec"
  type        = string
  default     = "EQUAL_TO"
}

variable "security_governance_condition_application_spec" {
  description = "Application specification for security governance"
  type = object({
    operator = string
    workloads = list(object({
      namespace = string
      kind      = string
    }))
  })
  default = null
}

variable "security_governance_condition_service_account_spec" {
  description = "Service account specification for security governance"
  type = object({
    operator         = string
    service_accounts = list(string)
  })
  default = null
}

variable "security_governance_condition_infra_ids" {
  description = "Infrastructure IDs for machine spec"
  type        = list(string)
  default     = []
}
```

**Pros**: Maintains flexibility, matches main.tf pattern
**Cons**: More complex, more variables to manage

### Option 2: Simplify the File (Recommended for E2E Test)

Replace the dynamic blocks with hardcoded values:

```hcl
# 07-security-governance.tf (Simplified)

resource "harness_chaos_security_governance_condition" "this" {
  depends_on = [
    harness_platform_environment.this,
    harness_platform_infrastructure.this,
    harness_chaos_infrastructure_v2.this,
  ]

  name        = var.security_governance_condition_name
  description = "Security condition to control chaos experiments"
  org_id      = local.org_id
  project_id  = local.project_id

  infra_type = "KubernetesV2"

  # Fault specifications
  fault_spec {
    operator = "EQUAL_TO"

    faults {
      fault_type = "FAULT"
      name       = "pod-delete"
    }

    faults {
      fault_type = "FAULT"
      name       = "container-kill"
    }

    faults {
      fault_type = "FAULT"
      name       = "pod-network-loss"
    }
  }

  # Kubernetes specific specifications
  k8s_spec {
    infra_spec {
      operator  = "EQUAL_TO"
      infra_ids = ["${harness_platform_environment.this.id}/${harness_chaos_infrastructure_v2.this.id}"]
    }

    # Application specification
    application_spec {
      operator = "EQUAL_TO"

      workloads {
        namespace = var.namespace
        kind      = "deployment"
      }

      workloads {
        namespace = var.namespace
        kind      = "statefulset"
      }
    }

    # Chaos service account specification
    chaos_service_account_spec {
      operator         = "EQUAL_TO"
      service_accounts = [var.chaos_service_account]
    }
  }

  lifecycle {
    ignore_changes = [name]
  }

  tags = [
    for k, v in merge(
      local.common_tags,
      {
        "platform" = "kubernetes"
      }
    ) : "${k}=${v}"
  ]
}

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
        "platform" = "kubernetes"
      }
    ) : "${k}=${v}"
  ]
}
```

**Pros**: Simple, clear, focused on K8s testing
**Cons**: Less flexible (but that's OK for e2e-test)

## Outputs Review

### ✅ Outputs are Correct

```hcl
output "security_governance_condition_id" {
  description = "ID of the security governance condition"
  value       = harness_chaos_security_governance_condition.this.id
}

output "security_governance_rule_id" {
  description = "ID of the security governance rule"
  value       = harness_chaos_security_governance_rule.this.id
}
```

**Status**: ✅ Both outputs are properly defined and reference correct resources

## Recommendation

### ✅ Use Option 2: Simplify the File

**Reasons**:
1. E2E test should be straightforward and easy to understand
2. Testing specific K8s scenario (not all platforms)
3. Reduces variable complexity
4. Matches the pattern used in other e2e-test files
5. Easier to maintain and debug

### Changes Needed:

1. ✅ Replace dynamic blocks with hardcoded values
2. ✅ Change `operator` from `"IN"` to `"EQUAL_TO"` (already done)
3. ✅ Change `fault_type` from `"KubernetesV2"` to `"FAULT"` (already done)
4. ✅ Remove `machine_spec` block (not needed for K8s)
5. ✅ Hardcode platform tag to `"kubernetes"`

## Current vs Recommended

### Current (Broken - Missing Variables)
```hcl
infra_type = var.security_governance_condition_infra_type  # ❌ Variable doesn't exist
operator = var.security_governance_condition_operator      # ❌ Variable doesn't exist
```

### Recommended (Working - Hardcoded)
```hcl
infra_type = "KubernetesV2"  # ✅ Hardcoded
operator = "EQUAL_TO"         # ✅ Hardcoded
```

## Implementation

I'll create the simplified version that:
- ✅ Removes all undefined variables
- ✅ Hardcodes values for K8s testing
- ✅ Maintains correct operator and fault_type values
- ✅ Keeps existing outputs unchanged
- ✅ Preserves time_windows dynamic block (uses defined variable)

## Summary

**Current Status**: ❌ File will fail terraform plan (missing variables)

**After Fix**: ✅ File will work correctly with simplified, hardcoded values

**Variables Needed**: Only 6 (already defined)
**Variables to Remove**: 7 (by hardcoding their values)

**Result**: Cleaner, simpler, more maintainable e2e-test file
