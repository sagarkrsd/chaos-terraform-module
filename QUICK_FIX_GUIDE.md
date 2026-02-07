# Quick Fix Guide - Experiment Errors

## Date: January 24, 2026

---

## ✅ Identity Issue: FIXED!

The identity generation is working correctly now.

---

## 🐛 Current Issues & Solutions

### Issue 1: "mongo: no documents in result" (10+ experiments)
**Cause**: Experiment templates don't exist  
**Solution**: Create experiment templates FIRST

```bash
# Make sure experiment templates are enabled and created
# Check if templates exist in your Harness account
```

---

### Issue 2: "failed to get experiment template: not found" (4 experiments)
**Cause**: Account/org level templates don't exist  
**Affected**:
- `enterprise_account_level`
- `enterprise_org_level`
- `account_level_reference`
- `org_level_reference`

**Solution**: Comment out these 4 experiments for now

---

### Issue 3: "invalid infra id format" (LOCAL imports)
**Cause**: Wrong `infra_ref` format  
**Correct Format**: `env_id/infra_id`

**Example**: `tf_demo_env/harnesstf11`

**Fix**:
```bash
# Set the correct format
export TF_VAR_infra_ref="tf_demo_env/harnesstf11"

# Or update variables.tf
variable "infra_ref" {
  default = "tf_demo_env/harnesstf11"
}
```

---

## 🚀 Quick Fix Steps

### Step 1: Set Correct Infrastructure Reference
```bash
export TF_VAR_infra_ref="your_env_id/your_infra_id"
# Example: export TF_VAR_infra_ref="tf_demo_env/harnesstf11"
```

### Step 2: Comment Out Account/Org Level Experiments
In `experiment_enterprise_templates_test.tf` and `experiment_import_types_test.tf`:
- Comment out `enterprise_account_level`
- Comment out `enterprise_org_level`
- Comment out `account_level_reference`
- Comment out `org_level_reference`

### Step 3: Ensure Experiment Templates Exist
Make sure the experiment templates are created before experiments:
- `simple_fault_only`
- `fault_with_probe_parallel`
- `fault_with_two_probes`
- `with_action`
- `multi_fault`
- `project_level`

### Step 4: Retry
```bash
terraform apply
```

---

## 📝 Summary

**3 Issues**:
1. ✅ Identity format - FIXED (auto-generated correctly)
2. ⚠️ Missing templates - Need to create templates first
3. ⚠️ Wrong infra format - Use `env_id/infra_id`

**Quick Wins**:
- Set `infra_ref` to correct format: `env_id/infra_id`
- Comment out 4 account/org experiments
- Ensure experiment templates exist

**Then**: Retry `terraform apply`
