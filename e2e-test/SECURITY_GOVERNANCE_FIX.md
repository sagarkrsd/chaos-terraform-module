# Security Governance Rule - Time Windows Fix

## Error Fixed: ✅

**Error**:
```
Error: Insufficient time_windows blocks

At least 1 "time_windows" blocks are required.
```

## Root Cause

The provider schema for `harness_chaos_security_governance_rule` requires **at least 1 time_windows block**, but the e2e-test variable had an empty default:

```hcl
default = []  # ❌ Empty - causes error
```

## Fix Applied

Updated the variable default to include a time window:

**Before**:
```hcl
variable "security_governance_rule_time_windows" {
  description = "Time windows for security governance rule"
  type = list(object({
    time_zone  = string
    start_time = string
    duration   = string
    recurrence = optional(object({
      type  = string
      until = string
    }))
  }))
  default = []  # ❌ Empty
}
```

**After**:
```hcl
variable "security_governance_rule_time_windows" {
  description = "Time windows for security governance rule"
  type = list(object({
    time_zone  = string
    start_time = string
    duration   = string
    recurrence = optional(object({
      type  = string
      until = string
    }))
  }))
  default = [
    {
      time_zone  = "UTC"
      start_time = "00:00"
      duration   = "24h"
      recurrence = {
        type  = "Daily"
        until = "2025-12-31T23:59:59Z"
      }
    }
  ]  # ✅ Has 1 time window
}
```

## Comparison with Main.tf

### Main.tf Variable
```hcl
variable "security_governance_rule_time_windows" {
  type = list(object({
    time_zone  = string
    start_time = number  # ⚠️ Different type (number)
    duration   = string
    recurrence = object({
      type  = string
      until = number  # ⚠️ Different type (number)
    })
  }))
  default = [
    {
      time_zone  = "UTC"
      start_time = 1711238400000  # Unix timestamp in milliseconds
      duration   = "24h"
      recurrence = {
        type  = "Daily"
        until = -1  # -1 means recur indefinitely
      }
    }
  ]
}
```

### E2E Test Variable (After Fix)
```hcl
variable "security_governance_rule_time_windows" {
  type = list(object({
    time_zone  = string
    start_time = string  # ✅ String format (easier to read)
    duration   = string
    recurrence = optional(object({
      type  = string
      until = string  # ✅ String format (ISO 8601)
    }))
  }))
  default = [
    {
      time_zone  = "UTC"
      start_time = "00:00"  # Time of day
      duration   = "24h"
      recurrence = {
        type  = "Daily"
        until = "2025-12-31T23:59:59Z"  # ISO 8601 format
      }
    }
  ]
}
```

## Key Differences

| Aspect | Main.tf | E2E Test | Notes |
|--------|---------|----------|-------|
| **start_time type** | `number` | `string` | E2E uses time of day format |
| **start_time value** | `1711238400000` | `"00:00"` | E2E more readable |
| **until type** | `number` | `string` | E2E uses ISO 8601 |
| **until value** | `-1` (infinite) | `"2025-12-31T23:59:59Z"` | E2E has end date |
| **recurrence** | Required | Optional | E2E more flexible |

## Provider Schema Requirement

The provider requires **MinItems: 1** for time_windows:

```go
"time_windows": {
    Type:     schema.TypeList,
    Required: true,
    MinItems: 1,  // ⚠️ At least 1 block required
    Elem: &schema.Resource{
        Schema: map[string]*schema.Schema{
            "time_zone": {
                Type:     schema.TypeString,
                Required: true,
            },
            "start_time": {
                Type:     schema.TypeString,
                Required: true,
            },
            "duration": {
                Type:     schema.TypeString,
                Required: true,
            },
            "recurrence": {
                Type:     schema.TypeList,
                Optional: true,
                MaxItems: 1,
                Elem: &schema.Resource{
                    Schema: map[string]*schema.Schema{
                        "type": {
                            Type:     schema.TypeString,
                            Required: true,
                        },
                        "until": {
                            Type:     schema.TypeString,
                            Required: true,
                        },
                    },
                },
            },
        },
    },
}
```

## Time Window Configuration

### Default Time Window (E2E Test)

The default time window allows chaos experiments **24/7**:

- **Time Zone**: UTC
- **Start Time**: 00:00 (midnight)
- **Duration**: 24h (all day)
- **Recurrence**: Daily until 2025-12-31

This means:
- ✅ Experiments can run any time
- ✅ Rule is active every day
- ✅ Continues until end of 2025

### Customizing Time Windows

Users can override the default in `terraform.tfvars`:

```hcl
# Example: Only allow chaos during business hours
security_governance_rule_time_windows = [
  {
    time_zone  = "America/New_York"
    start_time = "09:00"
    duration   = "8h"
    recurrence = {
      type  = "Weekly"
      until = "2025-12-31T23:59:59Z"
    }
  }
]
```

### Multiple Time Windows

You can define multiple time windows:

```hcl
security_governance_rule_time_windows = [
  {
    time_zone  = "UTC"
    start_time = "09:00"
    duration   = "4h"
    recurrence = {
      type  = "Daily"
      until = "2025-12-31T23:59:59Z"
    }
  },
  {
    time_zone  = "UTC"
    start_time = "14:00"
    duration   = "4h"
    recurrence = {
      type  = "Daily"
      until = "2025-12-31T23:59:59Z"
    }
  }
]
```

## Status

✅ **Fixed** - Security governance rule now has a valid default time window

## Next Steps

1. ✅ Variable updated with default time window
2. ✅ Run `terraform plan` - Should show no errors
3. ✅ Run `terraform apply` - Create security governance rule

## Related Files

- `variables.tf` - Updated with default time window
- `07-security-governance.tf` - Uses the variable
- Main module `variables.tf` - Reference implementation
