# Experiment Test Fixes Needed

## Date: January 24, 2026

---

## ✅ What's Already Fixed

1. **Identity generation** - Auto-generates correctly (lowercase, dashes)
2. **Import type** - All experiments have `import_type` field
3. **Hub references** - Correct format for different scopes

---

## 🔧 Fixes Still Needed

### 1. Infrastructure Reference Format

**Current**: `var.infra_ref` (may be wrong format)  
**Required**: `env_id/infra_id` format  
**Example**: `tf_demo_env/harnesstf11`

**Action**: Set in `terraform.tfvars` or environment:
```bash
export TF_VAR_infra_ref="tf_demo_env/harnesstf11"
```

Or in `variables.tf`:
```hcl
variable "infra_ref" {
  description = "Infrastructure reference in format: env_id/infra_id"
  type        = string
  default     = "tf_demo_env/harnesstf11"  # Update with your values
}
```

---

### 2. Template References

**Issue**: Some experiments use `length()` check, some don't  
**Required**: Direct reference (templates must exist)

**Current (inconsistent)**:
```hcl
template_identity = length(harness_chaos_experiment_template.simple_fault_only) > 0 ? harness_chaos_experiment_template.simple_fault_only[0].identity : null
```

**Should be**:
```hcl
template_identity = harness_chaos_experiment_template.simple_fault_only[0].identity
```

**Why**: The `depends_on` ensures templates exist, so `length()` check is unnecessary

---

### 3. Dependencies

**Current**: Only depends on template  
**Required**: Depend on both template AND infrastructure

**Current**:
```hcl
depends_on = [harness_chaos_experiment_template.simple_fault_only]
```

**Should be**:
```hcl
depends_on = [
  harness_chaos_experiment_template.simple_fault_only,
  harness_chaos_infrastructure_v2.this
]
```

---

### 4. Comment Out Missing Templates

**Templates that DON'T exist**:
- `harness_chaos_experiment_template.account_level`
- `harness_chaos_experiment_template.org_level`
- `harness_chaos_experiment_template.most_complex`

**Experiments to comment out**:
1. `enterprise_account_level` - references `account_level` template
2. `enterprise_org_level` - references `org_level` template  
3. `account_level_reference` - references `account_level` template
4. `org_level_reference` - references `org_level` template

---

### 5. Available Templates

**Templates that DO exist** (from `experiment_template_enterprise_tests.tf`):
- ✅ `simple_fault_only`
- ✅ `fault_with_probe_parallel`
- ✅ `fault_with_two_probes`

**Templates that DO exist** (from `experiment_template_complex_tests.tf`):
- ✅ `with_action`
- ✅ `two_actions`
- ✅ `multi_fault`

**Templates that DO exist** (from other files):
- ✅ `custom_fault_simple` (from `experiment_template_custom_fault_tests.tf`)
- ✅ `custom_fault_with_action_probe` (from `experiment_template_custom_fault_tests.tf`)
- ✅ `everything_custom` (from `experiment_template_everything_custom_test.tf`)

---

## 📋 Experiment Mapping

### experiment_enterprise_templates_test.tf

| Experiment | Template | Status |
|------------|----------|--------|
| from_enterprise_fault | simple_fault_only | ✅ EXISTS |
| from_enterprise_fault_probe_parallel | fault_with_probe_parallel | ✅ EXISTS |
| from_enterprise_two_probes | fault_with_two_probes | ✅ EXISTS |
| from_enterprise_with_action | with_action | ✅ EXISTS |
| from_enterprise_multi_fault | multi_fault | ✅ EXISTS |
| enterprise_account_level | account_level | ❌ MISSING - COMMENT OUT |
| enterprise_org_level | org_level | ❌ MISSING - COMMENT OUT |
| enterprise_project_level | project_level | ❌ MISSING - COMMENT OUT |
| enterprise_instance_1 | simple_fault_only | ✅ EXISTS |
| enterprise_instance_2 | simple_fault_only | ✅ EXISTS |
| enterprise_instance_3 | simple_fault_only | ✅ EXISTS |

### experiment_import_types_test.tf

| Experiment | Template | Status |
|------------|----------|--------|
| reference_import | simple_fault_only | ✅ EXISTS |
| local_import | simple_fault_only | ✅ EXISTS |
| account_level_reference | account_level | ❌ MISSING - COMMENT OUT |
| org_level_reference | org_level | ❌ MISSING - COMMENT OUT |
| project_level_local | project_level | ❌ MISSING - COMMENT OUT |
| reference_propagates_updates | simple_fault_only | ✅ EXISTS |
| local_independent | simple_fault_only | ✅ EXISTS |

---

## 🎯 Action Plan

### Step 1: Set Infrastructure Reference
```bash
export TF_VAR_infra_ref="tf_demo_env/harnesstf11"
```

### Step 2: Comment Out 5 Experiments
Comment out these experiments (missing templates):
1. `enterprise_account_level`
2. `enterprise_org_level`
3. `enterprise_project_level`
4. `account_level_reference`
5. `org_level_reference`
6. `project_level_local`

### Step 3: Verify Template Dependencies
Ensure all experiments have:
```hcl
depends_on = [
  harness_chaos_experiment_template.TEMPLATE_NAME,
  harness_chaos_infrastructure_v2.this
]
```

### Step 4: Enable Template Tests First
```bash
# Make sure experiment templates are created
# Check which template test files are enabled
```

### Step 5: Test
```bash
terraform validate
terraform plan
terraform apply
```

---

## 📊 Summary

**Total Experiments**: 18  
**Using Existing Templates**: 12 ✅  
**Using Missing Templates**: 6 ❌ (need to comment out)

**After Fixes**:
- 12 experiments should work
- 6 experiments commented out (until templates created)
- Correct infra_ref format
- Proper dependencies

---

## ✅ Expected Result

After applying these fixes:
- ✅ 12 experiments will create successfully
- ✅ All using existing templates
- ✅ Correct infra_ref format
- ✅ Proper dependency chain
