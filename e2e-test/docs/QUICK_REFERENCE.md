# E2E Test Quick Reference

## Resource Summary

| Category | Count | Scopes | Details |
|----------|-------|--------|---------|
| **Foundation** | 4 | - | Org, Project, K8s Connector, Git Connector |
| **Chaos Hubs** | 3 | Account, Org, Project | Custom Git-based hubs |
| **Action Templates** | 3 | Account, Org, Project | Script, Delay, Container actions |
| **Probe Templates** | 3 | Account, Org, Project | HTTP, CMD, K8s probes |
| **Fault Templates** | 3 | Account, Org, Project | Custom BYOC faults |
| **Experiment Templates** | 6 | Account, Org, Project | 2 per scope (custom + enterprise) |
| **Infrastructure** | 4 | Project | Env, Platform Infra, Chaos Infra, SD Agent |
| **Security Governance** | 2 | Project | Condition + Rule |
| **Experiments** | 6 | Project | 2 per scope (custom + enterprise) |
| **TOTAL** | **34** | - | Complete E2E stack |

## File Structure

```
e2e-test/
├── 01-foundation.tf              # Org, Project, Connectors
├── 02-chaos-hubs.tf              # Hubs at all scopes
├── 03-templates-account.tf       # Account-level templates (5)
├── 04-templates-org.tf           # Org-level templates (5)
├── 05-templates-project.tf       # Project-level templates (5)
├── 06-infrastructure.tf          # Env, Infra, Chaos Infra, SD Agent
├── 07-security-governance.tf     # Security rules
├── 08-experiments-project.tf     # Experiments from project templates
├── 09-experiments-org.tf         # Experiments from org templates
├── 10-experiments-account.tf     # Experiments from account templates
├── variables.tf                  # Input variables
├── outputs.tf                    # Output values
├── providers.tf                  # Provider config
├── version.tf                    # Version constraints
├── terraform.tfvars.example      # Example values
├── README.md                     # Overview
├── TESTING_GUIDE.md              # Detailed testing guide
└── QUICK_REFERENCE.md            # This file
```

## Quick Commands

### Setup
```bash
cd e2e-test
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
```

### Deploy
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Verify
```bash
terraform output summary
terraform state list | wc -l  # Should be ~34
terraform plan                # Should show no changes
```

### Cleanup
```bash
terraform destroy
```

## Key Variables to Configure

| Variable | Required | Example |
|----------|----------|---------|
| `git_repo_url` | ✅ | `https://github.com/org/repo` |
| `git_repo_name` | ✅ | `chaos-hub-repo` |
| `git_password_ref` | ✅ | `account.git_token` |
| `delegate_selectors` | ✅ | `["chaos-delegate"]` |
| `namespace` | ✅ | `chaos-e2e` |

## Template Composition

### Account Level
```
Action (Script) + Probe (HTTP) + Fault (BYOC)
    └── Experiment Template (Custom)
    └── Experiment Template (Enterprise: pod-delete)
```

### Org Level
```
Action (Delay) + Probe (CMD) + Fault (BYOC)
    └── Experiment Template (Custom)
    └── Experiment Template (Enterprise: pod-network-loss)
```

### Project Level
```
Action (Container) + Probe (K8s) + Fault (BYOC)
    └── Experiment Template (Custom)
    └── Experiment Template (Enterprise: container-kill)
```

## Experiment Import Types

| Experiment | Import Type | Behavior |
|------------|-------------|----------|
| from_account_custom | REFERENCE | Template updates propagate |
| from_account_enterprise | LOCAL | Full copy, independent |
| from_org_custom | REFERENCE | Template updates propagate |
| from_org_enterprise | LOCAL | Full copy, independent |
| from_project_custom | REFERENCE | Template updates propagate |
| from_project_enterprise | LOCAL | Full copy, independent |

## Hub Reference Format

| Scope | Format | Example |
|-------|--------|---------|
| Account | `account.{identity}` | `account.e2e_chaos_hub_account` |
| Org | `org.{identity}` | `org.e2e_chaos_hub_org` |
| Project | `{identity}` | `e2e_chaos_hub_project` |

## Dependency Chain

```
1. Organization
2. Project
3. Connectors (K8s + Git)
4. Chaos Hubs (Account → Org → Project)
5. Templates (Account → Org → Project)
6. Environment
7. Platform Infrastructure
8. Chaos Infrastructure V2
9. Service Discovery Agent
10. Security Governance (Condition + Rule)
11. Experiments
```

## Output Commands

### View All Resources
```bash
terraform output summary
```

### View Specific Scope
```bash
# Account level
terraform output action_template_account_id
terraform output probe_template_account_id
terraform output fault_template_account_id
terraform output experiment_template_account_custom_id
terraform output experiment_template_account_enterprise_id

# Org level
terraform output action_template_org_id
terraform output probe_template_org_id
terraform output fault_template_org_id
terraform output experiment_template_org_custom_id
terraform output experiment_template_org_enterprise_id

# Project level
terraform output action_template_project_id
terraform output probe_template_project_id
terraform output fault_template_project_id
terraform output experiment_template_project_custom_id
terraform output experiment_template_project_enterprise_id
```

### View Infrastructure
```bash
terraform output environment_id
terraform output infrastructure_id
terraform output chaos_infrastructure_id
terraform output infra_ref
```

### View Experiments
```bash
terraform output experiment_from_account_custom_identity
terraform output experiment_from_account_enterprise_identity
terraform output experiment_from_org_custom_identity
terraform output experiment_from_org_enterprise_identity
terraform output experiment_from_project_custom_identity
terraform output experiment_from_project_enterprise_identity
```

## Troubleshooting Quick Fixes

### Hub Creation Fails
```bash
# Check Git connector
terraform state show harness_platform_connector_git.chaos_hub

# Verify token
# Update git_password_ref in terraform.tfvars
```

### Template Creation Fails
```bash
# Check hub status
terraform output chaos_hub_project_id

# Verify in Harness UI that hub is active
```

### Experiment Creation Fails
```bash
# Check infrastructure
terraform output chaos_infrastructure_id

# Verify namespace exists
kubectl get ns chaos-e2e

# Check service account
kubectl get sa litmus-admin -n chaos-e2e
```

### Drift Detected
```bash
# View what changed
terraform plan

# Refresh state
terraform refresh

# Re-apply if needed
terraform apply
```

## Testing Checklist

- [ ] All 34 resources created
- [ ] No drift after apply
- [ ] All hubs active in UI
- [ ] All templates visible in UI
- [ ] Infrastructure active
- [ ] Experiments can be run
- [ ] Security rules active
- [ ] Clean destroy works

## Time Estimates

| Phase | Duration |
|-------|----------|
| Setup | 5 min |
| Foundation | 3 min |
| Hubs | 5 min |
| Templates | 15 min |
| Infrastructure | 7 min |
| Security | 3 min |
| Experiments | 7 min |
| **Total** | **45 min** |

## Resource Naming Convention

All resources follow this pattern:
- **Prefix**: `e2e` or `chaos_e2e`
- **Scope**: `account`, `org`, or `project`
- **Type**: `action`, `probe`, `fault`, `exp`, etc.
- **Variant**: `custom` or `enterprise`

Examples:
- `e2e-action-account` (Action template at account level)
- `e2e-exp-org-custom` (Custom experiment template at org level)
- `e2e-exp-from-project-enterprise` (Experiment from project enterprise template)

## Success Indicators

✅ **Green Lights:**
- `terraform apply` completes without errors
- `terraform plan` shows no changes
- All outputs return valid IDs
- Harness UI shows all resources
- Experiments can be executed

❌ **Red Flags:**
- Timeout errors (check delegate)
- "Not found" errors (check dependencies)
- Drift on every plan (check computed fields)
- Failed experiment runs (check infrastructure)

## Next Actions

After successful deployment:
1. Run experiments from Harness UI
2. Monitor chaos execution
3. Validate application resilience
4. Iterate on templates
5. Scale to production use cases
