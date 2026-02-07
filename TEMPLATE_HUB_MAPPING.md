# Template and Hub Mapping - CRITICAL FIX NEEDED

## Date: January 24, 2026

---

## 🎯 Key Rule

**ALL experiment templates are created in `project_level` hub**  
**ALL experiments MUST reference the same hub as their template**

---

## ✅ Available Experiment Templates

All templates are created in: `harness_chaos_hub_v2.project_level[0]`

### From experiment_template_enterprise_tests.tf:
1. ✅ `simple_fault_only` → `project_level` hub
2. ✅ `fault_with_probe_parallel` → `project_level` hub
3. ✅ `fault_with_two_probes` → `project_level` hub

### From experiment_template_complex_tests.tf:
4. ✅ `with_action` → `project_level` hub
5. ✅ `two_actions` → `project_level` hub
6. ✅ `multi_fault` → `project_level` hub

### From experiment_template_custom_fault_tests.tf:
7. ✅ `custom_fault_simple` → `project_level` hub
8. ✅ `custom_fault_with_action_probe` → `project_level` hub

### From experiment_template_everything_custom_test.tf:
9. ✅ `everything_custom` → `project_level` hub

### From experiment_template_advanced_multi_cloud_tests.tf:
10. ✅ `multi_cloud_complex` → `project_level` hub
11. ✅ `most_complex` → `project_level` hub

### From experiment_template_ui_match_test.tf:
12. ✅ `ui_match_test` → `project_level` hub

---

## ❌ Templates That DON'T Exist

These templates are referenced by experiments but NOT created:
1. ❌ `account_level` - NOT CREATED
2. ❌ `org_level` - NOT CREATED
3. ❌ `project_level` - NOT CREATED (confusing name - different from hub level)

---

## 🐛 Experiments with WRONG Hub References

### experiment_enterprise_templates_test.tf

| Experiment | Template Reference | Hub Reference | Status |
|------------|-------------------|---------------|--------|
| from_enterprise_fault | simple_fault_only | project_level | ✅ CORRECT |
| from_enterprise_fault_probe_parallel | fault_with_probe_parallel | project_level | ✅ CORRECT |
| from_enterprise_two_probes | fault_with_two_probes | project_level | ✅ CORRECT |
| from_enterprise_with_action | with_action | project_level | ✅ CORRECT |
| from_enterprise_multi_fault | multi_fault | project_level | ✅ CORRECT |
| **enterprise_account_level** | **account_level** | **account_level** | ❌ TEMPLATE DOESN'T EXIST |
| **enterprise_org_level** | **org_level** | **org_level** | ❌ TEMPLATE DOESN'T EXIST |
| **enterprise_project_level** | **project_level** | **project_level** | ❌ TEMPLATE DOESN'T EXIST |
| enterprise_instance_1 | simple_fault_only | project_level | ✅ CORRECT |
| enterprise_instance_2 | simple_fault_only | project_level | ✅ CORRECT |
| enterprise_instance_3 | simple_fault_only | project_level | ✅ CORRECT |

### experiment_import_types_test.tf

| Experiment | Template Reference | Hub Reference | Status |
|------------|-------------------|---------------|--------|
| reference_import | simple_fault_only | project_level | ✅ CORRECT |
| local_import | simple_fault_only | project_level | ✅ CORRECT |
| **account_level_reference** | **account_level** | **account_level** | ❌ TEMPLATE DOESN'T EXIST |
| **org_level_reference** | **org_level** | **org_level** | ❌ TEMPLATE DOESN'T EXIST |
| **project_level_local** | **project_level** | **project_level** | ❌ TEMPLATE DOESN'T EXIST |
| reference_propagates_updates | simple_fault_only | project_level | ✅ CORRECT |
| local_independent | simple_fault_only | project_level | ✅ CORRECT |

---

## 🔧 Required Fixes

### Option 1: Comment Out Experiments (RECOMMENDED)

Comment out these 6 experiments that reference non-existent templates:

**In experiment_enterprise_templates_test.tf**:
1. `enterprise_account_level`
2. `enterprise_org_level`
3. `enterprise_project_level`

**In experiment_import_types_test.tf**:
4. `account_level_reference`
5. `org_level_reference`
6. `project_level_local`

### Option 2: Create Missing Templates

Create these 3 experiment templates in `all_templates_multi_scope_tests.tf`:
1. `account_level` template in `project_level` hub
2. `org_level` template in `project_level` hub
3. `project_level` template in `project_level` hub

**Note**: Even though templates have "account_level" or "org_level" in their names, they would still be created in the `project_level` hub. The names are just for testing purposes.

---

## ✅ Correct Pattern

**Template Creation**:
```hcl
resource "harness_chaos_experiment_template" "my_template" {
  hub_identity = harness_chaos_hub_v2.project_level[0].identity
  # ... other fields
}
```

**Experiment Creation** (MUST match template's hub):
```hcl
resource "harness_chaos_experiment" "my_experiment" {
  template_identity = harness_chaos_experiment_template.my_template[0].identity
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity  # SAME as template
  # ... other fields
}
```

---

## 📊 Summary

**Total Experiments**: 18  
**Correct Hub/Template Mapping**: 12 ✅  
**Wrong Hub/Template Mapping**: 6 ❌ (templates don't exist)

**Action Required**: Comment out 6 experiments OR create 3 missing templates

---

## 🎯 Recommendation

**Comment out the 6 experiments** for now. This will allow the other 12 experiments to work correctly.

Later, if you want to test experiments at different scopes, you can:
1. Create templates in account/org level hubs (need to create those hubs first)
2. Update experiments to reference those templates and hubs
3. Remember: Experiments are always project-level, but can reference templates from any hub
