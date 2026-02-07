# Fix Drift Issue - Experiments Deleted from Harness

## Date: January 24, 2026

---

## 🎯 Problem

The experiments exist in **Terraform state** but were **deleted from Harness**. This causes the error:
```
Error: Internal Server Error: mongo: no documents in result
```

---

## 📊 Experiments in State (but deleted from Harness)

These experiments exist in state but not in Harness:
1. `harness_chaos_experiment.from_enterprise_fault[0]`
2. `harness_chaos_experiment.from_enterprise_fault_probe_parallel[0]`
3. `harness_chaos_experiment.from_enterprise_with_action[0]`
4. `harness_chaos_experiment.from_enterprise_multi_fault[0]`
5. `harness_chaos_experiment.enterprise_instance_1[0]`
6. `harness_chaos_experiment.enterprise_instance_3[0]`
7. `harness_chaos_experiment.reference_import[0]`
8. `harness_chaos_experiment.reference_propagates_updates[0]`
9. `harness_chaos_experiment.enterprise_project_level[0]` ⚠️ (should be commented out)

---

## 🔧 Solution: Remove from State and Recreate

### Step 1: Remove Experiments from State

```bash
# Remove all experiments from state
terraform state rm 'harness_chaos_experiment.from_enterprise_fault[0]'
terraform state rm 'harness_chaos_experiment.from_enterprise_fault_probe_parallel[0]'
terraform state rm 'harness_chaos_experiment.from_enterprise_with_action[0]'
terraform state rm 'harness_chaos_experiment.from_enterprise_multi_fault[0]'
terraform state rm 'harness_chaos_experiment.enterprise_instance_1[0]'
terraform state rm 'harness_chaos_experiment.enterprise_instance_3[0]'
terraform state rm 'harness_chaos_experiment.reference_import[0]'
terraform state rm 'harness_chaos_experiment.reference_propagates_updates[0]'
terraform state rm 'harness_chaos_experiment.enterprise_project_level[0]'
```

### Step 2: Verify State is Clean

```bash
terraform state list | grep harness_chaos_experiment
```

Should return empty (no experiments).

### Step 3: Run Terraform Plan

```bash
terraform plan
```

Should show that 8-9 experiments will be created (not 9 if enterprise_project_level is commented out).

### Step 4: Apply to Recreate Experiments

```bash
terraform apply
```

---

## 🚀 Quick Fix (One Command)

```bash
# Remove all experiments at once
terraform state rm \
  'harness_chaos_experiment.from_enterprise_fault[0]' \
  'harness_chaos_experiment.from_enterprise_fault_probe_parallel[0]' \
  'harness_chaos_experiment.from_enterprise_with_action[0]' \
  'harness_chaos_experiment.from_enterprise_multi_fault[0]' \
  'harness_chaos_experiment.enterprise_instance_1[0]' \
  'harness_chaos_experiment.enterprise_instance_3[0]' \
  'harness_chaos_experiment.reference_import[0]' \
  'harness_chaos_experiment.reference_propagates_updates[0]' \
  'harness_chaos_experiment.enterprise_project_level[0]'

# Then recreate
terraform apply
```

---

## ⚠️ Important Note

The experiment `enterprise_project_level` should have been commented out (it references a non-existent template). After removing from state, make sure it's commented out in the .tf file before running apply.

---

## ✅ Expected Result

After running these commands:
- State will be clean (no experiments)
- Terraform will create 8 new experiments (12 if we uncomment the ones we commented out earlier)
- All experiments will have correct:
  - Identity (auto-generated)
  - infra_ref (from local.infra_ref)
  - Template references
  - Hub references

---

## 🔍 Why This Happened

The experiments were likely:
1. Created in a previous run
2. Deleted manually from Harness UI
3. State still has them, causing drift

This is normal during development/testing. The fix is to sync the state with reality by removing them and recreating.
