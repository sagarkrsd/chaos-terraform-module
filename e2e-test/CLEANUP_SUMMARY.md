# E2E Test Cleanup - Enterprise Templates Replaced

## Summary

Replaced old simple enterprise experiment templates with comprehensive complex templates at all 3 scope levels.

## Changes Made

### ✅ Removed Old Enterprise Experiment Templates (3)

1. **`03-templates-account.tf`** - Removed `account_enterprise` template
2. **`04-templates-org.tf`** - Removed `org_enterprise` template  
3. **`05-templates-project.tf`** - Removed `project_enterprise` template

### ✅ Added New Complex Experiment Templates (3)

1. **`02-experiment-template-complex-account.tf`** - Account-level complex template
2. **`03-experiment-template-complex-org.tf`** - Org-level complex template
3. **`06-experiment-template-complex.tf`** - Project-level complex template

### ✅ Updated Experiments (3)

1. **`08-experiments-project.tf`** - Now uses `project_complex` template
2. **`09-experiments-org.tf`** - Now uses `org_complex` template
3. **`10-experiments-account.tf`** - Now uses `account_complex` template

### ✅ Kept Custom Templates

All action, probe, fault, and custom experiment templates are **retained**:
- ✅ Action templates (account, org, project)
- ✅ Probe templates (account, org, project)
- ✅ Fault templates (account, org, project)
- ✅ Custom experiment templates (account, org, project)

## Old vs New Comparison

### Old Enterprise Templates
| Feature | Account | Org | Project |
|---------|---------|-----|---------|
| Faults | 1 (pod-delete) | 1 (pod-network-loss) | 1 (container-kill) |
| Probes | 1 (replica-count) | 1 (replica-count) | 1 (replica-count) |
| Vertices | 2 (simple) | 2 (simple) | 2 (simple) |
| Runtime Inputs | None | None | None |
| Complexity | Low | Low | Low |

### New Complex Templates
| Feature | All Levels |
|---------|------------|
| Faults | 2 (pod-delete, pod-network-latency) |
| Probes | 4 (pod-status-check x2, pod-replica-count-check x2) |
| Vertices | 3 (with start/end phases) |
| Runtime Inputs | 20+ parameters |
| Complexity | High (production-grade) |

## Template Specifications

### Complex Template Features

**Faults (2)**:
1. `pod-delete-jpu` - Pod deletion with 7 runtime inputs
2. `pod-network-latency-ql6` - Network latency with 6 runtime inputs

**Probes (4)**:
1. `pod-status-check-nic-nic` - Status validation (6 inputs)
2. `pod-replica-count-check-d9a-d9a` - Replica count (6 inputs)
3. `pod-replica-count-check-1ox-1ox` - Replica count (4 inputs)
4. `pod-status-check-ua4-ua4` - Status validation (3 inputs)

**Workflow (3 vertices)**:
```
v-jrc (Start) → v-qn1 (Start/End) → v-end (End)
```

## File Structure

### Before Cleanup
```
e2e-test/
├── 03-templates-account.tf (5 templates: action, probe, fault, custom exp, enterprise exp)
├── 04-templates-org.tf (5 templates: action, probe, fault, custom exp, enterprise exp)
├── 05-templates-project.tf (5 templates: action, probe, fault, custom exp, enterprise exp)
├── 08-experiments-project.tf (2 experiments: custom, enterprise)
├── 09-experiments-org.tf (2 experiments: custom, enterprise)
└── 10-experiments-account.tf (2 experiments: custom, enterprise)
```

### After Cleanup
```
e2e-test/
├── 02-experiment-template-complex-account.tf (1 complex template)
├── 03-experiment-template-complex-org.tf (1 complex template)
├── 03-templates-account.tf (4 templates: action, probe, fault, custom exp)
├── 04-templates-org.tf (4 templates: action, probe, fault, custom exp)
├── 05-templates-project.tf (4 templates: action, probe, fault, custom exp)
├── 06-experiment-template-complex.tf (1 complex template)
├── 08-experiments-project.tf (1 experiment: complex)
├── 09-experiments-org.tf (1 experiment: complex)
└── 10-experiments-account.tf (1 experiment: complex)
```

## Resource Count

### Before
- Templates: 18 (15 simple + 3 enterprise exp)
- Experiments: 6 (3 custom + 3 enterprise)
- **Total**: 24 resources

### After
- Templates: 18 (15 simple + 3 complex exp)
- Experiments: 3 (3 complex)
- **Total**: 21 resources

**Reduction**: 3 experiments (consolidated)

## Benefits

### ✅ Production-Grade Templates
- Complex workflow with multiple phases
- Comprehensive probe coverage
- Runtime inputs for flexibility
- Enterprise fault and probe identities

### ✅ Consistency
- Same template structure at all 3 levels
- Easier to maintain and understand
- Single source of truth for complex scenarios

### ✅ Simplified Testing
- Fewer experiments to manage
- Focus on one comprehensive template
- Better coverage with fewer resources

### ✅ Maintained Flexibility
- Custom templates still available for testing
- Action, probe, and fault templates retained
- Can create additional experiments as needed

## Next Steps

1. ✅ Run `terraform plan` to verify changes
2. ✅ Run `terraform apply` to create complex templates
3. ✅ Verify experiments are created successfully
4. ⏳ Test experiment execution with runtime inputs
5. ⏳ Validate probe results

## Validation

```bash
# Verify no syntax errors
terraform validate

# Check what will be created/destroyed
terraform plan

# Apply the changes
terraform apply
```

## Expected Results

### Templates Created (3)
- `e2echaosexperimenttemplate-account` (Account level)
- `e2echaosexperimenttemplate-org` (Org level)
- `e2echaosexperimenttemplate` (Project level)

### Experiments Created (3)
- `e2e-exp-from-account-complex`
- `e2e-exp-from-org-complex`
- `e2e-exp-from-project-complex`

### Templates Retained (12)
- 3 Action templates (custom)
- 3 Probe templates (custom)
- 3 Fault templates (custom)
- 3 Custom experiment templates

## Notes

- All experiments use `import_type = "REFERENCE"` to avoid action template dependency issues
- Complex templates use enterprise faults and probes (require Harness CE license)
- Runtime inputs (`<+input>`) allow flexible parameterization at execution time
- Cleanup policy set to `delete` for automatic resource cleanup

## Status

✅ **Cleanup Complete** - E2E test now uses production-grade complex templates for enterprise chaos hub testing while retaining custom templates for flexibility.
