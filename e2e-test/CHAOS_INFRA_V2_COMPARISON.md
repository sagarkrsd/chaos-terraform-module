# Chaos Infrastructure V2 - Schema Comparison

## Summary: ✅ E2E Test Uses NEWER SCHEMA (Correct!)

The e2e-test uses the **newer, correct schema** for `harness_chaos_infrastructure_v2`, while main.tf uses an older flat schema.

## Schema Differences

### Main.tf (Older Flat Schema)
```hcl
resource "harness_chaos_infrastructure_v2" "this" {
  depends_on = [
    harness_platform_infrastructure.this
  ]

  // Required fields
  org_id         = local.org_id
  project_id     = local.project_id
  environment_id = harness_platform_environment.this.id
  infra_id       = harness_platform_infrastructure.this.id  # ⚠️ OLD
  name           = var.chaos_infra_name
  description    = var.chaos_infra_description

  // Optional fields
  namespace  = var.chaos_infra_namespace  # ⚠️ FLAT
  infra_type = var.chaos_infra_type

  ai_enabled           = var.chaos_ai_enabled
  insecure_skip_verify = var.chaos_insecure_skip_verify

  service_account = var.service_account_name  # ⚠️ FLAT
  tags            = local.tags_set
}
```

**Characteristics**:
- ⚠️ Uses `infra_id` (old field name)
- ⚠️ Flat structure (no nested blocks)
- ⚠️ Limited configuration options
- ⚠️ No `identity` field
- ⚠️ No `config` block

### E2E Test (Newer Nested Schema) ✅
```hcl
resource "harness_chaos_infrastructure_v2" "this" {
  depends_on = [
    harness_platform_infrastructure.this
  ]

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  identity   = var.chaos_infra_identity  # ✅ NEW
  name       = var.chaos_infra_name

  environment_id = harness_platform_environment.this.id
  infra_type     = var.chaos_infra_type

  config {  # ✅ NESTED BLOCK
    kubernetes {
      namespace                 = var.namespace
      service_account           = var.chaos_service_account
      enable_node_selector      = false
      enable_tolerations        = false
      install_chaos_components  = true
    }
  }

  tags = var.chaos_infra_tags
}
```

**Characteristics**:
- ✅ Uses `identity` (new field name)
- ✅ Nested `config { kubernetes { ... } }` block
- ✅ More configuration options
- ✅ Explicit control over components
- ✅ Follows current Terraform provider schema

## Field Mapping

| Main.tf (Old) | E2E Test (New) | Status |
|---------------|----------------|--------|
| `infra_id` | `identity` | ✅ Renamed |
| `namespace` (flat) | `config.kubernetes.namespace` | ✅ Nested |
| `service_account` (flat) | `config.kubernetes.service_account` | ✅ Nested |
| `ai_enabled` | ❌ Not present | ⚠️ Optional feature |
| `insecure_skip_verify` | ❌ Not present | ⚠️ Optional feature |
| `description` | ❌ Not present | ⚠️ Optional field |
| ❌ Not present | `config.kubernetes.enable_node_selector` | ✅ New option |
| ❌ Not present | `config.kubernetes.enable_tolerations` | ✅ New option |
| ❌ Not present | `config.kubernetes.install_chaos_components` | ✅ New option |

## Required Variables

### Main.tf Variables
```hcl
variable "chaos_infra_name" { }
variable "chaos_infra_description" { }
variable "chaos_infra_namespace" { }
variable "chaos_infra_type" { }
variable "chaos_ai_enabled" { }
variable "chaos_insecure_skip_verify" { }
variable "service_account_name" { }
```

### E2E Test Variables
```hcl
variable "chaos_infra_identity" {
  description = "Chaos infrastructure identity"
  type        = string
  default     = "chaos-e2e-infra"
}

variable "chaos_infra_name" {
  description = "Chaos infrastructure name"
  type        = string
  default     = "Chaos E2E Infrastructure V2"
}

variable "chaos_infra_type" {
  description = "Chaos infrastructure type"
  type        = string
  default     = "KUBERNETESV2"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "chaos-e2e"
}

variable "chaos_service_account" {
  description = "Chaos service account"
  type        = string
  default     = "litmus"
}

variable "chaos_infra_tags" {
  description = "Chaos infrastructure tags"
  type        = list(string)
  default     = ["e2e", "test", "chaos"]
}
```

## Configuration Options Comparison

### Main.tf (Limited Options)
- Basic namespace configuration
- Service account
- AI features toggle
- TLS verification toggle

### E2E Test (Comprehensive Options)
- Namespace configuration
- Service account
- Node selector control
- Tolerations control
- Chaos components installation control

## Why E2E Test Schema is Better

1. **✅ Follows Current Provider Schema** - Matches the latest Terraform provider implementation
2. **✅ More Flexible** - Nested config block allows for future expansion
3. **✅ Better Organization** - Kubernetes-specific settings grouped together
4. **✅ Explicit Control** - Clear flags for enabling/disabling features
5. **✅ Consistent Naming** - Uses `identity` like other chaos resources

## Recommendation

### For Main.tf
⚠️ **Consider updating to new schema** when convenient:
```hcl
resource "harness_chaos_infrastructure_v2" "this" {
  depends_on = [
    harness_platform_infrastructure.this
  ]

  org_id     = local.org_id
  project_id = local.project_id
  identity   = var.chaos_infra_identity  # Changed from infra_id
  name       = var.chaos_infra_name

  environment_id = harness_platform_environment.this.id
  infra_type     = var.chaos_infra_type

  config {  # New nested block
    kubernetes {
      namespace                 = var.chaos_infra_namespace
      service_account           = var.service_account_name
      enable_node_selector      = false
      enable_tolerations        = false
      install_chaos_components  = true
    }
  }

  tags = local.tags_set
}
```

### For E2E Test
✅ **No changes needed** - Already using the correct schema!

## Migration Notes

If updating main.tf to new schema:

1. **Rename field**: `infra_id` → `identity`
2. **Add config block**: Wrap kubernetes settings
3. **Move fields**: 
   - `namespace` → `config.kubernetes.namespace`
   - `service_account` → `config.kubernetes.service_account`
4. **Add new fields**:
   - `enable_node_selector = false`
   - `enable_tolerations = false`
   - `install_chaos_components = true`
5. **Remove optional fields** (if not needed):
   - `ai_enabled`
   - `insecure_skip_verify`
   - `description`

## Conclusion

✅ **E2E Test is using the CORRECT and CURRENT schema**

The e2e-test implementation is actually ahead of main.tf and follows the latest Terraform provider schema. This is the recommended approach for all new implementations.

**Status**: ✅ E2E Test Correct - No changes needed!
