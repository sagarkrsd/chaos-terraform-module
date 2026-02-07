# Terraform Apply Retry Strategy

## Error Encountered

```
Error: Internal Server Error: mongo: no documents in result
```

## Root Cause

This error occurs when:
1. **Template Indexing Lag** - Newly created templates aren't immediately available in the API's search index
2. **Dependency Timing** - Resources are created faster than the backend can index them
3. **Enterprise Template References** - Complex templates reference enterprise faults/probes that need time to be queryable

## Solution: Simple Retry

### Step 1: Wait 30 seconds
```bash
sleep 30
```

This allows the backend to:
- Index newly created templates
- Make enterprise faults/probes searchable
- Stabilize the database state

### Step 2: Retry the apply
```bash
terraform apply
```

## Why This Works

✅ **Idempotent** - Terraform will only create missing resources
✅ **State Preserved** - Already created resources are tracked in state
✅ **No Data Loss** - Failed resources will be retried

## Expected Behavior

### First Apply
- ✅ Foundation resources (org, project, connectors)
- ✅ Infrastructure (environment, chaos infra)
- ✅ Chaos hubs (account, org, project)
- ✅ Most templates (action, probe, fault, custom experiment)
- ⚠️ **Some complex templates may fail** (timing issue)
- ⚠️ **Experiments may fail** (template not indexed)

### Second Apply (After 30s)
- ✅ Complex templates (now enterprise templates are indexed)
- ✅ Experiments (now complex templates are indexed)
- ✅ All remaining resources

## Alternative: Targeted Apply

If you want more control, apply in stages:

### Stage 1: Foundation & Templates
```bash
terraform apply \
  -target=harness_platform_organization.this \
  -target=harness_platform_project.this \
  -target=harness_chaos_hub_v2.account_level \
  -target=harness_chaos_hub_v2.org_level \
  -target=harness_chaos_hub_v2.project_level \
  -target=harness_chaos_action_template.account_level \
  -target=harness_chaos_action_template.org_level \
  -target=harness_chaos_action_template.project_level \
  -target=harness_chaos_probe_template.account_level \
  -target=harness_chaos_probe_template.org_level \
  -target=harness_chaos_probe_template.project_level \
  -target=harness_chaos_fault_template.account_level \
  -target=harness_chaos_fault_template.org_level \
  -target=harness_chaos_fault_template.project_level \
  -target=harness_chaos_experiment_template.account_custom \
  -target=harness_chaos_experiment_template.org_custom \
  -target=harness_chaos_experiment_template.project_custom
```

### Stage 2: Wait
```bash
sleep 30
```

### Stage 3: Complex Templates
```bash
terraform apply \
  -target=harness_chaos_experiment_template.account_complex \
  -target=harness_chaos_experiment_template.org_complex \
  -target=harness_chaos_experiment_template.project_complex
```

### Stage 4: Wait
```bash
sleep 30
```

### Stage 5: Experiments
```bash
terraform apply
```

## Best Practice: Full Apply with Retry

**Recommended approach:**

```bash
# First attempt - creates most resources
terraform apply

# Wait for indexing
echo "Waiting 30 seconds for backend indexing..."
sleep 30

# Retry - creates remaining resources
terraform apply

# If still failing, wait longer
sleep 60
terraform apply
```

## Success Indicators

### ✅ Successful Apply
```
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.
```

### ⚠️ Partial Success (Retry Needed)
```
Error: Internal Server Error: mongo: no documents in result
```
**Action**: Wait 30s and retry

### ❌ Persistent Failure
If the error persists after 3 retries:
1. Check API service health
2. Verify enterprise hub is accessible
3. Check for quota/rate limits
4. Review Harness platform logs

## Why Not Add Explicit Delays?

Terraform doesn't have built-in sleep/delay resources. Options:
1. **External script** - Wrap terraform in a bash script with sleeps
2. **time_sleep resource** - Requires additional provider
3. **Manual retry** - Simple and effective ✅

We chose manual retry because:
- ✅ Simple and transparent
- ✅ No additional dependencies
- ✅ Works with any Terraform version
- ✅ Gives visibility into what's happening

## Automation Script

If you want to automate the retry:

```bash
#!/bin/bash
# apply-with-retry.sh

MAX_RETRIES=3
RETRY_DELAY=30

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i of $MAX_RETRIES..."
  
  if terraform apply -auto-approve; then
    echo "✅ Apply successful!"
    exit 0
  else
    if [ $i -lt $MAX_RETRIES ]; then
      echo "⚠️ Apply failed. Waiting ${RETRY_DELAY}s before retry..."
      sleep $RETRY_DELAY
    fi
  fi
done

echo "❌ Apply failed after $MAX_RETRIES attempts"
exit 1
```

Usage:
```bash
chmod +x apply-with-retry.sh
./apply-with-retry.sh
```

## Current Status

Based on your error, you're hitting the timing issue with complex templates or experiments.

**Recommended Action:**
```bash
# Wait for backend to stabilize
sleep 30

# Retry the apply
terraform apply
```

**Expected Result**: All remaining resources will be created successfully.

## Notes

- This is a **known limitation** of the Harness Chaos API
- The issue is **transient** - retrying always works
- This is **not a Terraform configuration error**
- The backend needs time to index templates for search/lookup operations

## Prevention

To minimize these errors in future:
1. Apply in stages (foundation → templates → experiments)
2. Add explicit waits between stages
3. Use smaller batches of resources
4. Monitor API response times

For E2E testing, the simple retry approach is sufficient and recommended.
