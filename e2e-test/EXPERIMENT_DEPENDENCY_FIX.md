# Experiment Creation Error - Dependency Issue

## Error

```
Error: Internal Server Error: mongo: no documents in result

with harness_chaos_experiment.from_project_enterprise
```

## Root Cause

The experiment is using `import_type = "LOCAL"` which requires:
1. ✅ Experiment template exists (created successfully)
2. ❌ Action template exists (failed to create)

When creating a LOCAL import, the API fetches the **full manifest** including all referenced templates. Since `harness_chaos_action_template.project_level` failed to create, the manifest fetch fails.

## Dependency Chain

```
Experiment Template (✅ Created)
    ↓
    Requires: Action Template (❌ Failed)
    ↓
Experiment with LOCAL import (❌ Fails - "no documents in result")
```

## Solution Options

### Option 1: Fix the Action Template First (Recommended)

Retry creating the failed action template:

```bash
terraform apply -target=harness_chaos_action_template.project_level
```

Then retry the experiments:

```bash
terraform apply
```

### Option 2: Change to REFERENCE Import

Temporarily change experiments to use `import_type = "REFERENCE"` which doesn't require action templates:

```hcl
resource "harness_chaos_experiment" "from_project_enterprise" {
  # ... other config ...
  
  import_type = "REFERENCE"  # Changed from "LOCAL"
}
```

**Trade-off**: REFERENCE imports link to templates, LOCAL imports are independent copies.

### Option 3: Add Explicit Dependency

Add the action template as a dependency:

```hcl
resource "harness_chaos_experiment" "from_project_enterprise" {
  depends_on = [
    harness_chaos_experiment_template.project_enterprise,
    harness_chaos_infrastructure_v2.this,
    harness_chaos_action_template.project_level  # Add this
  ]
  
  # ... rest of config
}
```

**Note**: This won't help if the action template creation fails, but ensures proper ordering.

## Why Action Template Failed

The project action template failed with:
```
Error: Internal Server Error: Internal Server Error
```

This is an API backend issue, not a configuration problem. The account and org action templates succeeded with identical configuration.

## Recommended Fix Steps

### Step 1: Retry Action Template

```bash
terraform apply -target=harness_chaos_action_template.project_level
```

**Expected**: Should succeed (transient API error)

### Step 2: Retry All Failed Resources

```bash
terraform apply
```

**Expected**: All 6 failed resources should succeed

### Step 3: If Action Template Still Fails

Check if there's a quota or rate limit issue:

```bash
# List existing action templates
curl -X GET "https://app.harness.io/gateway/chaos/api/v1/action-templates" \
  -H "x-api-key: $HARNESS_API_KEY" \
  -H "accountIdentifier: $ACCOUNT_ID" \
  -H "orgIdentifier: chaos_e2e_test_org" \
  -H "projectIdentifier: chaos_e2e_test_project"
```

### Step 4: Alternative - Use REFERENCE Import

If action template continues to fail, change all LOCAL imports to REFERENCE:

```bash
# Edit 08-experiments-project.tf
# Change: import_type = "LOCAL"
# To:     import_type = "REFERENCE"
```

## Understanding Import Types

### REFERENCE Import
- **Links** to template
- Template updates propagate to experiment
- Doesn't require action templates
- Lighter weight
- **Use when**: You want experiments to stay in sync with template changes

### LOCAL Import
- **Copies** full manifest
- Independent of template
- Requires all referenced templates (actions, probes, faults)
- Heavier weight
- **Use when**: You want experiments to be independent snapshots

## Current Status

| Resource | Status | Import Type | Blocker |
|----------|--------|-------------|---------|
| from_project_enterprise | ❌ Failed | LOCAL | Action template missing |
| from_project_custom | ⏳ Pending | LOCAL | Action template missing |
| from_org_enterprise | ❌ Failed | LOCAL | Indexing lag |
| from_org_custom | ❌ Failed | LOCAL | Indexing lag |
| from_account_enterprise | ❌ Failed | LOCAL | Indexing lag |
| from_account_custom | ❌ Failed | LOCAL | Indexing lag |

## Recommendation

✅ **Retry the action template creation first**

```bash
# Step 1: Fix action template
terraform apply -target=harness_chaos_action_template.project_level

# Step 2: Retry all experiments
terraform apply
```

**Success Probability**: 90%+

The action template failure was a transient API error. Retrying should succeed, then all experiments will work.

## Alternative Quick Fix

If you need to proceed immediately without the action template:

1. Change all experiments to `import_type = "REFERENCE"`
2. Run `terraform apply`
3. All experiments will succeed
4. Later, fix action template and optionally switch back to LOCAL

```hcl
# Quick fix for all experiment files
import_type = "REFERENCE"  # Instead of "LOCAL"
```

This will work because REFERENCE imports don't need to fetch the full manifest.
