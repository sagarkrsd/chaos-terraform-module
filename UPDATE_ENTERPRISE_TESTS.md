# Quick Update Guide for Enterprise Templates Test File

## Add `import_type` to All Experiments

For each experiment resource in `experiment_enterprise_templates_test.tf`, add this line after `infra_ref`:

```hcl
  import_type       = "REFERENCE"  # Template reference
```

## Example

**Before**:
```hcl
resource "harness_chaos_experiment" "from_enterprise_fault" {
  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = ...
  hub_identity      = var.enterprise_hub_identity
  name              = "..."
  infra_ref         = var.infra_ref
  
  description = "..."
  tags        = [...]
}
```

**After**:
```hcl
resource "harness_chaos_experiment" "from_enterprise_fault" {
  org_id            = var.org_id
  project_id        = var.project_id
  template_identity = ...
  hub_identity      = var.enterprise_hub_identity
  name              = "..."
  infra_ref         = var.infra_ref
  import_type       = "REFERENCE"  # Template reference
  
  description = "..."
  tags        = [...]
}
```

## Apply to All 13 Experiments

1. from_enterprise_fault
2. from_enterprise_fault_probe_parallel
3. from_enterprise_two_probes
4. from_enterprise_with_action
5. from_enterprise_multi_fault
6. from_enterprise_most_complex
7. from_enterprise_account_level
8. from_enterprise_org_level
9. from_enterprise_project_level
10. enterprise_instance_1
11. enterprise_instance_2
12. enterprise_instance_3

**Optional**: Change instance_3 to use `import_type = "LOCAL"` for variety.
