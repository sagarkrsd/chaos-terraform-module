# Proper Cleanup Order for Chaos Resources

## Date: January 24, 2026

---

## 🎯 Issue

When destroying resources, you're getting errors:
- "cannot delete experiment template as it is referenced by experiment"
- "fault template is referenced by faults"

**This is CORRECT behavior** - you can't delete a template while it's being used!

---

## ✅ Proper Destruction Order

Resources must be destroyed in **reverse dependency order**:

### 1. Delete Experiments FIRST
```bash
terraform destroy -target=harness_chaos_experiment.from_enterprise_fault
terraform destroy -target=harness_chaos_experiment.from_enterprise_fault_probe_parallel
terraform destroy -target=harness_chaos_experiment.from_enterprise_with_action
terraform destroy -target=harness_chaos_experiment.from_enterprise_multi_fault
terraform destroy -target=harness_chaos_experiment.enterprise_instance_1
terraform destroy -target=harness_chaos_experiment.enterprise_instance_3
terraform destroy -target=harness_chaos_experiment.reference_import
terraform destroy -target=harness_chaos_experiment.reference_propagates_updates
```

Or all at once:
```bash
terraform destroy \
  -target='harness_chaos_experiment.from_enterprise_fault[0]' \
  -target='harness_chaos_experiment.from_enterprise_fault_probe_parallel[0]' \
  -target='harness_chaos_experiment.from_enterprise_with_action[0]' \
  -target='harness_chaos_experiment.from_enterprise_multi_fault[0]' \
  -target='harness_chaos_experiment.enterprise_instance_1[0]' \
  -target='harness_chaos_experiment.enterprise_instance_3[0]' \
  -target='harness_chaos_experiment.reference_import[0]' \
  -target='harness_chaos_experiment.reference_propagates_updates[0]'
```

### 2. Delete Experiment Templates SECOND
```bash
terraform destroy -target=harness_chaos_experiment_template.simple_fault_only
terraform destroy -target=harness_chaos_experiment_template.fault_with_probe_parallel
terraform destroy -target=harness_chaos_experiment_template.fault_with_two_probes
terraform destroy -target=harness_chaos_experiment_template.with_action
terraform destroy -target=harness_chaos_experiment_template.multi_fault
```

### 3. Delete Fault/Probe/Action Templates THIRD
```bash
terraform destroy -target=harness_chaos_fault_template.custom
# ... other templates
```

### 4. Delete Everything Else
```bash
terraform destroy
```

---

## 🚀 Quick Cleanup (Recommended)

Instead of destroying individual resources, just remove experiments from state and let them be orphaned:

```bash
# Remove experiments from state (don't delete from Harness)
terraform state rm 'harness_chaos_experiment.from_enterprise_fault[0]'
terraform state rm 'harness_chaos_experiment.from_enterprise_fault_probe_parallel[0]'
terraform state rm 'harness_chaos_experiment.from_enterprise_with_action[0]'
terraform state rm 'harness_chaos_experiment.from_enterprise_multi_fault[0]'
terraform state rm 'harness_chaos_experiment.enterprise_instance_1[0]'
terraform state rm 'harness_chaos_experiment.enterprise_instance_3[0]'
terraform state rm 'harness_chaos_experiment.reference_import[0]'
terraform state rm 'harness_chaos_experiment.reference_propagates_updates[0]'

# Then destroy everything else
terraform destroy
```

This leaves the experiments in Harness but removes them from Terraform state, allowing templates to be deleted.

---

## 📊 Dependency Chain

```
Experiments (DELETE FIRST)
    ↓ depends on
Experiment Templates (DELETE SECOND)
    ↓ depends on
Fault/Probe/Action Templates (DELETE THIRD)
    ↓ depends on
Hubs (DELETE FOURTH)
    ↓ depends on
Infrastructure, Environment, etc. (DELETE LAST)
```

---

## ⚠️ Important Notes

1. **This is NOT an error** - It's Harness protecting you from breaking references
2. **Experiments must be deleted first** before their templates
3. **Templates must be deleted** before the resources they reference (faults, probes, actions)

---

## 🎯 What This Means

**Good News**: Your experiments are working correctly! They're properly referencing the templates, which is why the templates can't be deleted.

**To Test**: Instead of destroying, just recreate the experiments:

```bash
# Remove from state
terraform state rm 'harness_chaos_experiment.from_enterprise_fault[0]'
# ... (remove all experiments)

# Recreate
terraform apply
```

This will test the creation without needing to destroy everything.

---

## ✅ Recommended Action for Testing

**Don't destroy** - just remove experiments from state and recreate:

```bash
# 1. Remove experiments from state
terraform state rm \
  'harness_chaos_experiment.from_enterprise_fault[0]' \
  'harness_chaos_experiment.from_enterprise_fault_probe_parallel[0]' \
  'harness_chaos_experiment.from_enterprise_with_action[0]' \
  'harness_chaos_experiment.from_enterprise_multi_fault[0]' \
  'harness_chaos_experiment.enterprise_instance_1[0]' \
  'harness_chaos_experiment.enterprise_instance_3[0]' \
  'harness_chaos_experiment.reference_import[0]' \
  'harness_chaos_experiment.reference_propagates_updates[0]'

# 2. Recreate with all our fixes
terraform apply
```

This tests the creation logic without the hassle of destroying dependencies!
