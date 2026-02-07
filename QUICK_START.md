# Quick Start - Experiment Tests

## ✅ All Tests Ready! Run in 3 Steps:

### Step 1: Set Variables (30 seconds)
```bash
export TF_VAR_infra_ref="your-k8s-infra-id"  # REQUIRED!
export TF_VAR_org_id="your-org-id"
export TF_VAR_experiment_name_suffix="$(date +%s)"
```

### Step 2: Enable Tests (10 seconds)
```bash
# Enable all 27 experiment tests
export TF_VAR_enable_experiment_custom_templates_test=true
export TF_VAR_enable_experiment_enterprise_templates_test=true
export TF_VAR_enable_experiment_import_types_test=true
```

### Step 3: Run (2 minutes)
```bash
terraform validate
terraform apply -auto-approve
```

---

## 📊 What Gets Created

### 27 Experiments Total:
- **19 REFERENCE** imports (template references)
- **8 LOCAL** imports (full copies with manifest)

### Distribution:
- 7 from custom templates
- 13 from enterprise templates
- 7 import type & scope tests

---

## ✅ Verify Success

```bash
# Check outputs
terraform output | grep experiment_

# Verify REFERENCE has template_details
terraform output reference_import_has_template_details
# Should show: true

# Verify LOCAL has manifest
terraform output local_import_has_manifest
# Should show: true
```

---

## 🎯 Key Features Tested

✅ REFERENCE imports (template references)  
✅ LOCAL imports (full copies)  
✅ Account/Org/Project scopes  
✅ Hub reference formatting  
✅ Manifest storage  
✅ Template update propagation  
✅ Runtime inputs  
✅ Multiple instances  

---

## 📚 Full Documentation

See `ALL_TESTS_READY.md` for complete details!
