# Inline Chaos Resources - Implementation Needed

## Date: January 24, 2026

---

## 🎯 Problem

When deleting templates, we get errors:
- "fault template is referenced by faults"
- Cannot delete templates while inline resources exist

**Root Cause**: Experiment templates create inline faults/probes/actions that reference the templates. These inline resources are NOT managed by Terraform, so they can't be deleted automatically.

---

## 📊 What Are Inline Resources?

When you create an experiment template with faults/probes/actions, Harness creates:

1. **Experiment Template** (managed by Terraform ✅)
2. **Inline Faults** (NOT managed ❌) - References fault templates
3. **Inline Probes** (NOT managed ❌) - References probe templates
4. **Inline Actions** (NOT managed ❌) - References action templates

**The inline resources block template deletion!**

---

## 🔧 Solution: Implement Read + Delete Resources

We need to implement **lightweight resources** for inline faults, probes, and actions with:
- ✅ **Read** - Get current state
- ✅ **Delete** - Remove inline resource
- ❌ **Create** - NOT needed (created by experiment templates)
- ❌ **Update** - NOT needed (immutable)

---

## 📚 Available APIs

### Inline Faults
- **Get**: `FaultApiService.GetFault(accountIdentifier, identity)`
- **List**: `FaultApiService.ListFaultv2(accountIdentifier, opts)`
- **Delete**: `FaultApiService.DeleteFault(accountIdentifier, identity)`

### Inline Probes
- **Get**: `DefaultApiService.GetProbe(accountIdentifier, orgId, projectId, probeId)`
- **Delete**: `DefaultApiService.DeleteProbe(accountIdentifier, orgId, projectId, probeId)`

### Inline Actions
- **Get**: `DefaultApiService.GetAction(accountIdentifier, orgId, projectId, identity)`
- **Delete**: `DefaultApiService.DeleteAction(accountIdentifier, orgId, projectId, identity)`

---

## 🎯 Implementation Plan

### Phase 1: Inline Fault Resource (2-3 hours)

**Location**: `/internal/service/chaos/inline_fault/`

**Files to Create**:
1. `resource_inline_fault.go` - Read + Delete only
2. `data_source_inline_fault.go` - Lookup by identity

**Schema** (minimal):
```go
"identity": {
    Type:     schema.TypeString,
    Required: true,
    ForceNew: true,
},
"org_id": {
    Type:     schema.TypeString,
    Required: true,
    ForceNew: true,
},
"project_id": {
    Type:     schema.TypeString,
    Required: true,
    ForceNew: true,
},
// Computed fields from API
"name": {
    Type:     schema.TypeString,
    Computed: true,
},
"fault_template_identity": {
    Type:     schema.TypeString,
    Computed: true,
},
```

**CRUD Functions**:
- ✅ `resourceInlineFaultRead()` - Call GetFault API
- ✅ `resourceInlineFaultDelete()` - Call DeleteFault API
- ❌ `resourceInlineFaultCreate()` - Return error "use experiment template"
- ❌ `resourceInlineFaultUpdate()` - Return error "immutable"

**Import Format**: `account_id/org_id/project_id/identity`

---

### Phase 2: Inline Probe Resource (2-3 hours)

**Location**: `/internal/service/chaos/inline_probe/`

**Similar structure** to inline_fault

**Import Format**: `account_id/org_id/project_id/probe_id`

---

### Phase 3: Inline Action Resource (2-3 hours)

**Location**: `/internal/service/chaos/inline_action/`

**Similar structure** to inline_fault

**Import Format**: `account_id/org_id/project_id/identity`

---

## 🚀 Usage Pattern

### Step 1: Import Inline Resources

After creating experiment templates, import the inline resources:

```bash
# Import inline fault
terraform import harness_chaos_inline_fault.my_fault \
  account_id/org_id/project_id/fault-identity

# Import inline probe
terraform import harness_chaos_inline_probe.my_probe \
  account_id/org_id/project_id/probe-id

# Import inline action
terraform import harness_chaos_inline_action.my_action \
  account_id/org_id/project_id/action-identity
```

### Step 2: Add to Terraform Config

```hcl
resource "harness_chaos_inline_fault" "my_fault" {
  identity   = "fault-identity"
  org_id     = "my-org"
  project_id = "my-project"
  
  # All other fields computed from API
  
  lifecycle {
    prevent_destroy = false  # Allow deletion
  }
}
```

### Step 3: Destroy in Correct Order

```bash
# 1. Delete experiments
terraform destroy -target=harness_chaos_experiment.my_exp

# 2. Delete inline resources (now managed)
terraform destroy -target=harness_chaos_inline_fault.my_fault
terraform destroy -target=harness_chaos_inline_probe.my_probe
terraform destroy -target=harness_chaos_inline_action.my_action

# 3. Delete experiment templates
terraform destroy -target=harness_chaos_experiment_template.my_template

# 4. Delete templates
terraform destroy -target=harness_chaos_fault_template.my_fault_template
```

---

## ⚡ Alternative: Auto-Discovery

**Advanced Option**: Implement a helper that auto-discovers and imports inline resources:

```bash
# Script to auto-import inline resources
./scripts/import_inline_resources.sh
```

This would:
1. List all experiment templates
2. Parse their specs to find inline faults/probes/actions
3. Auto-generate import commands
4. Auto-generate Terraform config

---

## 📊 Effort Estimation

| Task | Time | Priority |
|------|------|----------|
| Inline Fault Resource | 2-3 hours | HIGH |
| Inline Probe Resource | 2-3 hours | HIGH |
| Inline Action Resource | 2-3 hours | HIGH |
| Documentation | 1 hour | MEDIUM |
| Auto-discovery script | 3-4 hours | LOW |
| **Total** | **10-13 hours** | |

---

## ✅ Benefits

1. **Clean Deletion** - Can delete templates without errors
2. **Dependency Management** - Terraform tracks all dependencies
3. **State Tracking** - Know what inline resources exist
4. **Lifecycle Management** - Control when inline resources are deleted

---

## 🎯 Recommendation

**Implement Phase 1 (Inline Fault) first** to validate the pattern, then replicate for probes and actions.

**Alternative Short-term Workaround**: Manually delete inline resources via API/UI before destroying templates.

---

## 📝 Resource Names

- `harness_chaos_inline_fault`
- `harness_chaos_inline_probe`
- `harness_chaos_inline_action`

---

## 🔍 How to Find Inline Resources

### Via API:
```bash
# List all faults
GET /rest/v2/faults?accountIdentifier=...

# List all probes
GET /rest/probes?accountIdentifier=...&organizationIdentifier=...&projectIdentifier=...

# List all actions
GET /rest/actions?accountIdentifier=...&organizationIdentifier=...&projectIdentifier=...
```

### Via Terraform State:
After importing, they'll show in `terraform state list`:
```
harness_chaos_inline_fault.fault1
harness_chaos_inline_probe.probe1
harness_chaos_inline_action.action1
```

---

## 🎊 Expected Outcome

After implementation:
- ✅ Can delete templates cleanly
- ✅ Terraform manages all chaos resources
- ✅ No more "referenced by" errors
- ✅ Clean dependency chain

**Confidence**: 95% - APIs exist, pattern is proven (similar to other resources)
