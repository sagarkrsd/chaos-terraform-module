# Manual Cleanup Required

## Current Situation

The project-level experiments (`from_project_reference` and `from_project_local`) were created in Harness but are now causing "duplicate experiment found" errors because they exist in the backend but were removed from Terraform state.

## Solution Options

### Option 1: Delete Experiments from Harness UI (RECOMMENDED)

1. Log into Harness UI
2. Navigate to: **Chaos Engineering** → **Experiments**
3. Delete these 2 experiments:
   - `E2E-Exp-From-Project-Reference` (identity: `e2e-exp-from-project-reference`)
   - `E2E-Exp-From-Project-Local` (identity: `e2e-exp-from-project-local`)
4. Run: `terraform apply`

### Option 2: Import Experiments Back into State

```bash
# Set environment variables for credentials
export TF_VAR_harness_account_id="your-account-id"
export TF_VAR_harness_platform_api_key="your-api-key"

# Import the experiments
terraform import harness_chaos_experiment.from_project_reference \
  chaos_e2e_test_org/chaos_e2e_test_project/e2e-exp-from-project-reference

terraform import harness_chaos_experiment.from_project_local \
  chaos_e2e_test_org/chaos_e2e_test_project/e2e-exp-from-project-local

# Then apply
terraform apply
```

### Option 3: Use Terraform to Destroy Them

```bash
# Add them back to state temporarily
terraform import harness_chaos_experiment.from_project_reference \
  chaos_e2e_test_org/chaos_e2e_test_project/e2e-exp-from-project-reference

terraform import harness_chaos_experiment.from_project_local \
  chaos_e2e_test_org/chaos_e2e_test_project/e2e-exp-from-project-local

# Destroy just these resources
terraform destroy -target=harness_chaos_experiment.from_project_reference \
  -target=harness_chaos_experiment.from_project_local

# Then apply to recreate them
terraform apply
```

## Why This Happened

1. The experiments were created during the first `terraform apply`
2. They were marked as "tainted" in state due to a refresh error
3. We removed them from state with `terraform state rm`
4. But they still exist in Harness backend
5. Now Terraform tries to create them again → "duplicate" error

## Other Errors to Address After Cleanup

### 1. Action Template Error
```
Error: Internal Server Error: Internal Server Error
with harness_chaos_action_template.project_level
```
**Solution**: Retry after 30-60 seconds (backend timing issue)

### 2. Security Governance Condition Error
```
Error: Internal server error: internal system error
with harness_chaos_security_governance_condition.this
```
**Solution**: Retry after 30-60 seconds (backend timing issue)

### 3. Org/Account Experiments - Template Not Found
```
Error: failed to get experiment template: not found
```
**Solution**: Wait 30-60 seconds for templates to be indexed, then retry

## Recommended Workflow

1. **Delete the 2 project experiments from Harness UI** (fastest)
2. **Wait 60 seconds** for backend to stabilize
3. **Run**: `terraform apply`
4. **If still errors**: Wait another 60 seconds and retry
5. **Expected**: All resources created successfully

## Alternative: Start Fresh

If you want to start completely fresh:

```bash
# Destroy everything
terraform destroy

# Wait 60 seconds
sleep 60

# Apply everything
terraform apply
```

This will take longer but guarantees a clean state.

## Status Summary

| Resource | Status | Action Needed |
|----------|--------|---------------|
| Project experiments (2) | ❌ Duplicate in backend | Delete from UI or import |
| Org/Account experiments (4) | ⏳ Template not indexed | Wait 60s + retry |
| Action template (project) | ⏳ Backend timing | Wait 60s + retry |
| Security governance | ⏳ Backend timing | Wait 60s + retry |
| All other resources | ✅ Created | None |

## Quick Fix Command

After deleting the 2 project experiments from Harness UI:

```bash
sleep 60 && terraform apply
```

This should create all remaining resources successfully.
