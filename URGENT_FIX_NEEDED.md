# URGENT: Experiment Templates Not Created

## Date: January 24, 2026

---

## 🚨 Problem

The experiments are failing because the experiment templates they reference **don't exist in the state**.

### Error
```
Error: Internal Server Error: mongo: no documents in result
```

---

## 📊 What Exists vs What's Needed

### Templates That EXIST (in state):
✅ `with_action`
✅ `two_actions`
✅ `account_level`
✅ `custom_fault_simple`
✅ `custom_fault_with_action_probe`
✅ `everything_custom`

### Templates That DON'T EXIST (but experiments reference):
❌ `simple_fault_only`
❌ `fault_with_probe_parallel`
❌ `fault_with_two_probes`
❌ `multi_fault`

---

## 🔧 Solution Options

### Option 1: Create Missing Templates (RECOMMENDED)

Run terraform apply to create ONLY the experiment templates first:

```bash
# Create experiment templates
terraform apply -target=harness_chaos_experiment_template.simple_fault_only
terraform apply -target=harness_chaos_experiment_template.fault_with_probe_parallel
terraform apply -target=harness_chaos_experiment_template.fault_with_two_probes
terraform apply -target=harness_chaos_experiment_template.multi_fault
```

Then run full apply:
```bash
terraform apply
```

### Option 2: Update Experiments to Use Existing Templates

Update all experiments to reference `with_action` instead of `simple_fault_only`:

**In experiment_enterprise_templates_test.tf**:
```hcl
# Change from:
template_identity = harness_chaos_experiment_template.simple_fault_only[0].identity

# To:
template_identity = harness_chaos_experiment_template.with_action[0].identity
```

**In experiment_import_types_test.tf**:
```hcl
# Change from:
template_identity = harness_chaos_experiment_template.simple_fault_only[0].identity

# To:
template_identity = harness_chaos_experiment_template.with_action[0].identity
```

---

## 🎯 Quick Fix Commands

### Create All Missing Templates at Once:
```bash
terraform apply \
  -target=harness_chaos_experiment_template.simple_fault_only \
  -target=harness_chaos_experiment_template.fault_with_probe_parallel \
  -target=harness_chaos_experiment_template.fault_with_two_probes \
  -target=harness_chaos_experiment_template.multi_fault
```

### Then Create Experiments:
```bash
terraform apply
```

---

## 📝 Why This Happened

The experiment template resources have `count = 1`, but they were never created. Possible reasons:
1. Templates were created in a previous run but destroyed
2. Templates were never applied
3. State file doesn't include these templates

---

## ✅ Recommended Action

**Run this command**:
```bash
terraform apply \
  -target=harness_chaos_experiment_template.simple_fault_only \
  -target=harness_chaos_experiment_template.fault_with_probe_parallel \
  -target=harness_chaos_experiment_template.fault_with_two_probes \
  -target=harness_chaos_experiment_template.multi_fault
```

This will create the 4 missing templates, then you can run `terraform apply` to create the experiments.

---

## 🔍 Verify Templates Exist

After creating templates, verify:
```bash
terraform state list | grep experiment_template
```

Should show:
- `harness_chaos_experiment_template.simple_fault_only[0]`
- `harness_chaos_experiment_template.fault_with_probe_parallel[0]`
- `harness_chaos_experiment_template.fault_with_two_probes[0]`
- `harness_chaos_experiment_template.multi_fault[0]`
