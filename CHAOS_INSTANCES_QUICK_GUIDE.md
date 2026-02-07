# Chaos Instances - Quick Implementation Guide

## Folder Structure

```
/internal/service/chaos/
├── fault/                    # NEW - Fault instances
│   ├── resource_fault.go
│   ├── data_source_fault.go
│   └── README.md
├── probe/                    # NEW - Probe instances
│   ├── resource_probe.go
│   ├── data_source_probe.go
│   └── README.md
├── action/                   # NEW - Action instances
│   ├── resource_action.go
│   ├── data_source_action.go
│   └── README.md
```

---

## Resource Names

- `harness_chaos_fault` - Fault instances
- `harness_chaos_probe` - Probe instances
- `harness_chaos_action` - Action instances

---

## SDK APIs

### Fault (api_fault.go)
- **Get**: `c.FaultApi.GetFault(ctx, accountId, identity, opts)`
- **Delete**: `c.FaultApi.DeleteFault(ctx, accountId, identity, opts)`
- **List**: `c.FaultApi.ListFaultv2(ctx, accountId, opts)`

### Probe (api_default.go)
- **Get**: `c.DefaultApi.GetProbe(ctx, accountId, orgId, projectId, probeId)`
- **Delete**: `c.DefaultApi.DeleteProbe(ctx, accountId, orgId, projectId, probeId)`

### Action (api_default.go)
- **Get**: `c.DefaultApi.GetAction(ctx, accountId, orgId, projectId, identity)`
- **Delete**: `c.DefaultApi.DeleteAction(ctx, accountId, orgId, projectId, identity)`

---

## Implementation Pattern

All three resources follow the same pattern:

### CRUD Functions
- ✅ **Read** - Get current state from API
- ✅ **Delete** - Remove instance
- ❌ **Create** - Return error (created by experiment templates)
- ❌ **Update** - Return error (immutable)

### Import Format
- Fault: `org_id/project_id/identity`
- Probe: `org_id/project_id/probe_id`
- Action: `org_id/project_id/identity`

---

## Minimal Schema

```go
// Required fields
"identity": {
    Type:     schema.TypeString,
    Required: true,
    ForceNew: true,
},
"org_id": {
    Type:     schema.TypeString,
    Optional: true,
    Computed: true,
    ForceNew: true,
},
"project_id": {
    Type:     schema.TypeString,
    Optional: true,
    Computed: true,
    ForceNew: true,
},

// Computed fields (from API)
"name": {
    Type:     schema.TypeString,
    Computed: true,
},
"template_identity": {
    Type:     schema.TypeString,
    Computed: true,
    Description: "Identity of the template this instance was created from",
},
```

---

## Usage Example

```hcl
# Import existing fault instance
resource "harness_chaos_fault" "my_fault" {
  identity   = "fault-abc123"
  org_id     = "my-org"
  project_id = "my-project"
}

# Import existing probe instance
resource "harness_chaos_probe" "my_probe" {
  identity   = "probe-xyz789"
  org_id     = "my-org"
  project_id = "my-project"
}

# Import existing action instance
resource "harness_chaos_action" "my_action" {
  identity   = "action-def456"
  org_id     = "my-org"
  project_id = "my-project"
}
```

---

## Import Commands

```bash
# Import fault
terraform import harness_chaos_fault.my_fault \
  my-org/my-project/fault-abc123

# Import probe
terraform import harness_chaos_probe.my_probe \
  my-org/my-project/probe-xyz789

# Import action
terraform import harness_chaos_action.my_action \
  my-org/my-project/action-def456
```

---

## Deletion Order

```
1. Experiments (delete first)
2. Faults, Probes, Actions (delete second) ← NEW RESOURCES
3. Experiment Templates (delete third)
4. Fault/Probe/Action Templates (delete fourth)
5. Hubs (delete last)
```

---

## Estimated Effort

| Task | Time |
|------|------|
| Fault resource | 2-3 hours |
| Probe resource | 2-3 hours |
| Action resource | 2-3 hours |
| Testing | 2 hours |
| Documentation | 1 hour |
| **Total** | **9-13 hours** |

---

## Benefits

✅ Clean template deletion  
✅ Proper dependency management  
✅ Terraform tracks all chaos resources  
✅ No more "referenced by" errors  

---

## Priority

**HIGH** - Blocks clean infrastructure teardown
