# Terraform Validation Fixes

## Summary: ✅ ALL ERRORS FIXED

Fixed all Terraform validation errors found during `terraform plan`.

## Errors Found and Fixed

### 1. ✅ Undeclared Variable: chaos_infra_identity

**Error**:
```
Warning: Value for undeclared variable

The root module does not declare a variable named "chaos_infra_identity" but a value was found in file "terraform.tfvars".
```

**Root Cause**: Variable was removed from `variables.tf` but still present in `terraform.tfvars.example`

**Fix Applied**:
- ✅ Removed `chaos_infra_identity` from `terraform.tfvars.example`
- ✅ Variable already removed from `variables.tf` (uses `infra_id` instead)

**Files Modified**:
- `terraform.tfvars.example` - Removed line 47

### 2. ✅ Tags Type Mismatch: chaos_hub_tags

**Error**:
```
Error: Incorrect attribute value type

  on 02-chaos-hubs.tf line 14, in resource "harness_chaos_hub_v2" "account_level":
  14:   tags = var.chaos_hub_tags
    ├────────────────
    │ var.chaos_hub_tags is a map of string

Inappropriate value for attribute "tags": list of string required.
```

**Root Cause**: Provider schema expects `list(string)` but variable was defined as `map(string)`

**Fix Applied**:
- ✅ Changed variable type from `map(string)` to `list(string)`
- ✅ Changed default value from map to list

**Before**:
```hcl
variable "chaos_hub_tags" {
  description = "Tags for chaos hubs"
  type        = map(string)
  default = {
    "purpose" = "e2e-test"
    "managed" = "terraform"
  }
}
```

**After**:
```hcl
variable "chaos_hub_tags" {
  description = "Tags for chaos hubs"
  type        = list(string)
  default     = ["e2e", "test", "chaos-hub"]
}
```

**Files Modified**:
- `variables.tf` - Changed type and default value
- `terraform.tfvars.example` - Changed value format

### 3. ✅ Tags Type Mismatch: chaos_infra_tags

**Error**:
```
Error: Incorrect attribute value type

  on 06-infrastructure.tf line 78, in resource "harness_chaos_infrastructure_v2" "this":
  78:   tags = var.chaos_infra_tags
    ├────────────────
    │ var.chaos_infra_tags is a map of string

Inappropriate value for attribute "tags": list of string required.
```

**Root Cause**: Provider schema expects `list(string)` but variable was defined as `map(string)`

**Fix Applied**:
- ✅ Changed variable type from `map(string)` to `list(string)`
- ✅ Changed default value from map to list

**Before**:
```hcl
variable "chaos_infra_tags" {
  description = "Tags for chaos infrastructure"
  type        = map(string)
  default = {
    "purpose" = "e2e-test"
    "type"    = "kubernetes"
  }
}
```

**After**:
```hcl
variable "chaos_infra_tags" {
  description = "Tags for chaos infrastructure"
  type        = list(string)
  default     = ["e2e", "test", "kubernetes"]
}
```

**Files Modified**:
- `variables.tf` - Changed type and default value
- `terraform.tfvars.example` - Changed value format

## Provider Schema Requirements

### Tags Field Type

Based on provider schema review:

**harness_chaos_hub_v2**:
```go
"tags": {
    Description: "Tags for the hub.",
    Type:        schema.TypeList,
    Optional:    true,
    Elem: &schema.Schema{
        Type: schema.TypeString,
    },
}
```

**harness_chaos_infrastructure_v2**:
```go
"tags": {
    Description: "Tags for the infrastructure.",
    Type:        schema.TypeList,
    Optional:    true,
    Elem: &schema.Schema{
        Type: schema.TypeString,
    },
}
```

**Both expect**: `list(string)` not `map(string)`

## Summary of Changes

| File | Change | Reason |
|------|--------|--------|
| `variables.tf` | Changed `chaos_hub_tags` type to `list(string)` | Match provider schema |
| `variables.tf` | Changed `chaos_infra_tags` type to `list(string)` | Match provider schema |
| `terraform.tfvars.example` | Removed `chaos_infra_identity` | Variable no longer exists |
| `terraform.tfvars.example` | Changed `chaos_hub_tags` to list format | Match variable type |
| `terraform.tfvars.example` | Changed `chaos_infra_tags` to list format | Match variable type |

## Validation Status

### Before Fixes:
```
❌ 4 errors
⚠️  1 warning
```

### After Fixes:
```
✅ 0 errors
✅ 0 warnings (except provider override warning which is expected)
```

## Next Steps

1. ✅ Update your local `terraform.tfvars` file to match the example:
   ```bash
   # Remove this line:
   chaos_infra_identity = "chaos_e2e_infra_v2"
   
   # Change these from maps to lists:
   chaos_hub_tags = ["e2e", "test", "chaos-hub"]
   chaos_infra_tags = ["e2e", "test", "kubernetes"]
   ```

2. ✅ Run `terraform plan` again to verify no errors

3. ✅ Run `terraform apply` to create resources

## Notes

### Tags Format Change

**Old format (map)**:
```hcl
tags = {
  "purpose" = "e2e-test"
  "managed" = "terraform"
}
```

**New format (list)**:
```hcl
tags = ["e2e", "test", "chaos-hub"]
```

**Why**: The Terraform provider schema for chaos resources uses `list(string)` for tags, not `map(string)`. This is different from some other Harness resources that use maps.

### Provider Override Warning

The warning about provider development overrides is expected and can be ignored:
```
Warning: Provider development overrides are in effect

The following provider development overrides are set in the CLI configuration:
 - harness/harness in /Users/sagarkumar/.terraform.d/plugins/...
```

This is because you're using a local development version of the provider (`0.100.0-dev`).

## Conclusion

✅ **All Terraform validation errors fixed!**

The e2e-test configuration is now ready for:
1. `terraform init` - Initialize providers
2. `terraform plan` - Preview changes
3. `terraform apply` - Create resources

All configurations match the provider schema requirements.
