# Experiment Scope Clarification - CRITICAL ⚠️

## Date: January 24, 2026

---

## 🎯 KEY FACT: Experiments are PROJECT-LEVEL ONLY

### ✅ CORRECT Understanding

**Experiments**:
- ✅ Can ONLY be created at **PROJECT level**
- ✅ MUST have both `org_id` and `project_id` populated
- ✅ Cannot be created at account or org level

**Templates/Hubs/Resources**:
- ✅ Can be created at **ALL scopes** (account/org/project)
- ✅ Can be **referenced** by experiments from any scope
- ✅ Hub reference formatting still applies based on template's scope

---

## 📊 Scope Matrix

| Resource Type | Account Level | Org Level | Project Level |
|---------------|---------------|-----------|---------------|
| **Chaos Hub** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Fault Template** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Probe Template** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Action Template** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Experiment Template** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Experiment** | ❌ NO | ❌ NO | ✅ YES ONLY |

---

## 🔧 Correct Experiment Configuration

### ✅ CORRECT: Project-Level Experiment Referencing Account-Level Template

```hcl
resource "harness_chaos_experiment" "example" {
  # Experiment is at PROJECT level (required)
  org_id     = "my-org"
  project_id = "my-project"
  
  # Can reference template from ACCOUNT level
  template_identity = harness_chaos_experiment_template.account_level[0].identity
  hub_identity      = harness_chaos_hub_v2.account_level[0].identity
  
  # Other fields...
  name      = "My Experiment"
  infra_ref = "k8s-cluster"
}
```

### ❌ INCORRECT: Trying to Create Account-Level Experiment

```hcl
resource "harness_chaos_experiment" "wrong" {
  # THIS WILL NOT WORK!
  org_id     = ""  # Empty for account level
  project_id = ""  # Empty for account level
  
  # This configuration is INVALID
  # Experiments MUST be at project level
}
```

---

## 🎯 Hub Reference Formatting (Still Applies)

Even though experiments are project-level only, the hub reference formatting still applies based on **where the template/hub is located**:

### Template at Account Level
```hcl
resource "harness_chaos_experiment" "from_account_template" {
  org_id     = "my-org"      # Project level
  project_id = "my-project"  # Project level
  
  # Template is at account level
  template_identity = harness_chaos_experiment_template.account_level[0].identity
  hub_identity      = harness_chaos_hub_v2.account_level[0].identity
  # Provider formats as: "account.{hub_identity}"
}
```

### Template at Org Level
```hcl
resource "harness_chaos_experiment" "from_org_template" {
  org_id     = "my-org"      # Project level
  project_id = "my-project"  # Project level
  
  # Template is at org level
  template_identity = harness_chaos_experiment_template.org_level[0].identity
  hub_identity      = harness_chaos_hub_v2.org_level[0].identity
  # Provider formats as: "org.{hub_identity}"
}
```

### Template at Project Level
```hcl
resource "harness_chaos_experiment" "from_project_template" {
  org_id     = "my-org"      # Project level
  project_id = "my-project"  # Project level
  
  # Template is at project level
  template_identity = harness_chaos_experiment_template.project_level[0].identity
  hub_identity      = harness_chaos_hub_v2.project_level[0].identity
  # Provider formats as: "{hub_identity}" (no prefix)
}
```

---

## 🔄 Updated Test Naming

### ❌ OLD (Incorrect Names)
- "Account-level experiment" ← WRONG, experiments can't be account-level
- "Org-level experiment" ← WRONG, experiments can't be org-level

### ✅ NEW (Correct Names)
- "Experiment referencing account-level template"
- "Experiment referencing org-level template"
- "Experiment referencing project-level template"

---

## 📝 Test File Updates Needed

### experiment_enterprise_templates_test.tf

**Test 7**: Change from:
```hcl
description = "Account-level experiment from enterprise template"
```

To:
```hcl
description = "Experiment referencing account-level template"
```

**Test 8**: Change from:
```hcl
description = "Org-level experiment from enterprise template"
```

To:
```hcl
description = "Experiment referencing org-level template"
```

**Test 9**: Already correct:
```hcl
description = "Project-level experiment from enterprise template"
```

### experiment_import_types_test.tf

**Test 3**: Change from:
```hcl
description = "Account-level experiment with REFERENCE import"
```

To:
```hcl
description = "Experiment referencing account-level template (REFERENCE)"
```

**Test 4**: Change from:
```hcl
description = "Org-level experiment with REFERENCE import"
```

To:
```hcl
description = "Experiment referencing org-level template (REFERENCE)"
```

**Test 5**: Already correct (project-level template reference)

---

## 🎯 Key Takeaways

1. **Experiments**: PROJECT-LEVEL ONLY
   - Always have `org_id` and `project_id` populated
   - Cannot be created at account or org level

2. **Templates/Hubs**: ALL SCOPES
   - Can be created at account/org/project levels
   - Can be referenced by experiments from any scope

3. **Hub Reference Formatting**: Based on Template Location
   - Account template → `account.{hub}`
   - Org template → `org.{hub}`
   - Project template → `{hub}`

4. **Test Descriptions**: Should reflect reality
   - "Experiment referencing X-level template"
   - NOT "X-level experiment"

---

## ✅ Corrected Understanding

**What we're testing**:
- ✅ Experiments (at project level) referencing account-level templates
- ✅ Experiments (at project level) referencing org-level templates
- ✅ Experiments (at project level) referencing project-level templates

**What we're NOT testing**:
- ❌ Account-level experiments (don't exist)
- ❌ Org-level experiments (don't exist)

---

## 🚀 Impact on Tests

All experiments in our test files are correctly configured with:
- `org_id` = populated
- `project_id` = populated

The only changes needed are:
1. Update descriptions to be accurate
2. Update comments to reflect correct understanding
3. Update documentation

**No code changes needed** - just clarification! ✅
