# E2E Testing Guide

This guide provides step-by-step instructions for running the end-to-end chaos engineering test.

## Prerequisites Checklist

Before running this test, ensure you have:

- [ ] **Harness Account** with Chaos Engineering module enabled
- [ ] **Harness API Key** with appropriate permissions
- [ ] **Kubernetes Cluster** (v1.20+) with at least 4GB RAM and 2 CPUs available
- [ ] **Harness Delegate** installed in the Kubernetes cluster
- [ ] **Terraform** (v1.0+) installed locally
- [ ] **kubectl** configured to access your cluster

## Quick Start

### 1. Set Environment Variables

```bash
export HARNESS_ACCOUNT_ID="your-account-id"
export HARNESS_API_KEY="your-api-key"
export HARNESS_ENDPOINT="https://app.harness.io/gateway"
```

### 2. Configure Variables

```bash
cd e2e-test
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
# Minimum required configuration
delegate_selectors = ["your-delegate-name"]
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Verify Deployment

```bash
terraform output summary
```

## Detailed Testing Steps

### Phase 1: Foundation Setup (2-3 minutes)

This phase creates the organization, project, and connectors.

```bash
# Verify organization created
terraform output org_id

# Verify project created
terraform output project_id
```

**Expected Result:**
- 1 Organization
- 1 Project
- 2 Connectors (Kubernetes + Git)

### Phase 2: Chaos Hubs (3-5 minutes)

This phase creates chaos hubs at all three scopes.

```bash
# Verify all hubs created
terraform output chaos_hub_account_id
terraform output chaos_hub_org_id
terraform output chaos_hub_project_id
```

**Expected Result:**
- 3 Chaos Hubs (Account, Org, Project)

### Phase 3: Templates (10-15 minutes)

This phase creates 15 templates across all scopes.

```bash
# Verify account-level templates
terraform output action_template_account_id
terraform output probe_template_account_id
terraform output fault_template_account_id
terraform output experiment_template_account_custom_id
terraform output experiment_template_account_enterprise_id

# Verify org-level templates
terraform output action_template_org_id
terraform output probe_template_org_id
terraform output fault_template_org_id
terraform output experiment_template_org_custom_id
terraform output experiment_template_org_enterprise_id

# Verify project-level templates
terraform output action_template_project_id
terraform output probe_template_project_id
terraform output fault_template_project_id
terraform output experiment_template_project_custom_id
terraform output experiment_template_project_enterprise_id
```

**Expected Result:**
- 15 Templates total:
  - 3 Action Templates (account, org, project)
  - 3 Probe Templates (account, org, project)
  - 3 Fault Templates (account, org, project)
  - 6 Experiment Templates (2 per scope: custom + enterprise)

**Troubleshooting:**
- If template creation fails, verify hub is active
- Check template syntax in Harness UI

### Phase 4: Infrastructure (5-7 minutes)

This phase creates the infrastructure stack.

```bash
# Verify infrastructure
terraform output environment_id
terraform output infrastructure_id
terraform output chaos_infrastructure_id
terraform output service_discovery_agent_id
```

**Expected Result:**
- 1 Environment
- 1 Platform Infrastructure
- 1 Chaos Infrastructure V2
- 1 Service Discovery Agent

**Troubleshooting:**
- If chaos infrastructure fails, check namespace exists: `kubectl get ns chaos-e2e`
- Verify service account: `kubectl get sa litmus-admin -n chaos-e2e`

### Phase 5: Security Governance (2-3 minutes)

This phase creates security rules and conditions.

```bash
# Verify security governance
terraform output security_governance_condition_id
terraform output security_governance_rule_id
```

**Expected Result:**
- 1 Security Governance Condition
- 1 Security Governance Rule

### Phase 6: Experiments (5-7 minutes)

This phase creates 6 experiments from templates at all scopes.

```bash
# Verify experiments
terraform output experiment_from_account_custom_identity
terraform output experiment_from_account_enterprise_identity
terraform output experiment_from_org_custom_identity
terraform output experiment_from_org_enterprise_identity
terraform output experiment_from_project_custom_identity
terraform output experiment_from_project_enterprise_identity
```

**Expected Result:**
- 6 Experiments:
  - 2 from Account templates (custom + enterprise)
  - 2 from Org templates (custom + enterprise)
  - 2 from Project templates (custom + enterprise)

**Troubleshooting:**
- If experiment creation fails, verify infrastructure is active
- Check experiment template exists in correct hub

## Validation Tests

### Test 1: Verify Resource Count

```bash
terraform state list | wc -l
```

**Expected:** ~35-40 resources

### Test 2: Verify No Drift

```bash
terraform plan
```

**Expected:** "No changes. Your infrastructure matches the configuration."

### Test 3: Verify Experiments Can Run

In Harness UI:
1. Navigate to Chaos Engineering → Experiments
2. Select any experiment
3. Click "Run Experiment"
4. Verify experiment starts successfully

### Test 4: Verify Template Inheritance

```bash
# Check account template is accessible from project
terraform output experiment_from_account_custom_identity

# Verify in Harness UI that experiment references account-level template
```

### Test 5: Verify Import Types

```bash
# REFERENCE import - template_details should be populated
terraform state show harness_chaos_experiment.from_account_custom

# LOCAL import - manifest should be populated
terraform state show harness_chaos_experiment.from_account_enterprise
```

## Resource Dependency Graph

```
Organization
    └── Project
            ├── Connectors (K8s + Git)
            ├── Chaos Hubs (Account, Org, Project)
            │       └── Templates (Action, Probe, Fault, Experiment)
            ├── Environment
            │       └── Platform Infrastructure
            │               └── Chaos Infrastructure V2
            │                       ├── Service Discovery Agent
            │                       └── Experiments
            └── Security Governance (Condition + Rule)
```

## Performance Benchmarks

| Phase | Expected Duration | Resources Created |
|-------|------------------|-------------------|
| Foundation | 2-3 min | 4 |
| Chaos Hubs | 3-5 min | 3 |
| Templates | 10-15 min | 15 |
| Infrastructure | 5-7 min | 4 |
| Security | 2-3 min | 2 |
| Experiments | 5-7 min | 6 |
| **Total** | **27-40 min** | **34** |

## Cleanup

### Full Cleanup

```bash
terraform destroy
```

**Note:** Resources will be destroyed in reverse dependency order:
1. Experiments
2. Security Governance
3. Infrastructure
4. Templates
5. Hubs
6. Connectors
7. Project
8. Organization

### Partial Cleanup

To keep foundation but remove experiments:

```bash
# Remove specific experiments
terraform destroy -target=harness_chaos_experiment.from_project_custom
terraform destroy -target=harness_chaos_experiment.from_project_enterprise
# ... repeat for other experiments
```

## Common Issues and Solutions

### Issue 1: Hub Creation Fails

**Error:** "Failed to connect to Git repository"

**Solution:**
1. Verify Git token is valid
2. Check token has repository access
3. Ensure repository exists and is accessible

### Issue 2: Template Creation Fails

**Error:** "Hub not found"

**Solution:**
1. Wait for hub to be fully active (check Harness UI)
2. Verify hub identity matches exactly
3. Check scope-based hub reference format

### Issue 3: Experiment Creation Fails

**Error:** "Infrastructure not found"

**Solution:**
1. Verify chaos infrastructure is active
2. Check infra_ref format: `env_id/infra_id`
3. Ensure namespace exists in cluster

### Issue 4: Drift Detected

**Error:** "Plan shows changes after apply"

**Solution:**
1. Check for computed fields changing
2. Verify API is returning consistent data
3. Add fields to lifecycle ignore_changes if needed

## Advanced Testing

### Test Multi-Scope Access

Verify that project-level experiments can access templates from all scopes:

```bash
# Create experiment using account template from project scope
# This should work due to scope inheritance
```

### Test Import Types

```bash
# Test REFERENCE import
terraform state show harness_chaos_experiment.from_project_custom | grep import_type
# Should show: import_type = "REFERENCE"

# Test LOCAL import
terraform state show harness_chaos_experiment.from_project_enterprise | grep import_type
# Should show: import_type = "LOCAL"
```

### Test Template Updates

1. Update an experiment template
2. Run `terraform apply`
3. Verify REFERENCE experiments reflect changes
4. Verify LOCAL experiments remain unchanged

## Success Criteria

✅ All 34 resources created successfully
✅ No drift detected after apply
✅ All experiments can be run from UI
✅ Templates accessible across scopes
✅ Security governance rules active
✅ Service discovery agent running
✅ Clean destroy without errors

## Next Steps

After successful E2E test:

1. **Run Experiments**: Execute experiments from Harness UI
2. **Monitor Results**: Check experiment execution logs
3. **Validate Resilience**: Verify application behavior during chaos
4. **Iterate**: Modify templates and re-run experiments
5. **Scale**: Add more experiments and templates as needed

## Support

For issues or questions:
- Check Harness docs: https://docs.harness.io/
- Review provider docs: https://registry.terraform.io/providers/harness/harness
- File issues: https://github.com/harness/terraform-provider-harness/issues
