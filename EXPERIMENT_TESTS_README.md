# Chaos Experiment Tests - Comprehensive Guide

## Overview

This directory contains comprehensive Terraform tests for Harness Chaos Experiments created from Experiment Templates. The tests cover two main scenarios:

1. **Custom Templates** - Experiments from templates using custom fault/probe/action templates
2. **Enterprise Templates** - Experiments from templates using enterprise hub templates

## Test Files

### 1. `experiment_custom_templates_test.tf`
Tests experiments created from experiment templates that use **CUSTOM** templates:
- Custom fault templates
- Custom probe templates  
- Custom action templates

**Test Cases (7 total)**:
- ✅ Experiment from custom fault template
- ✅ Experiment from custom fault + action + probe template
- ✅ Experiment from everything custom template
- ✅ Experiment with runtime inputs
- ✅ Multiple experiments from same template (2 instances)

### 1b. `experiment_import_types_test.tf` ⭐ NEW
Tests **REFERENCE vs LOCAL** import types and scope-based hub references:
- REFERENCE import (template reference)
- LOCAL import (full copy with manifest)
- Account/Org/Project scope experiments

**Test Cases (7 total)**:
- ✅ REFERENCE import (default)
- ✅ LOCAL import (full copy)
- ✅ Account-level experiment (REFERENCE)
- ✅ Org-level experiment (REFERENCE)
- ✅ Project-level experiment (LOCAL)
- ✅ REFERENCE propagates template updates
- ✅ LOCAL is independent of template changes

### 2. `experiment_enterprise_templates_test.tf`
Tests experiments created from experiment templates that use **ENTERPRISE** templates:
- Enterprise fault templates
- Enterprise probe templates
- Enterprise action templates

**Test Cases (13 total)**:
- ✅ Experiment from simple enterprise fault
- ✅ Experiment from fault + probe (parallel)
- ✅ Experiment from fault + two probes
- ✅ Experiment with enterprise action
- ✅ Experiment with multiple faults
- ✅ Experiment from most complex template
- ✅ Account-level experiment
- ✅ Org-level experiment
- ✅ Project-level experiment
- ✅ Multiple experiments from same template (3 instances)

## Prerequisites

### 1. Infrastructure Setup
You MUST have a Kubernetes infrastructure configured in Harness:

```bash
# Get your infrastructure ID from Harness UI:
# Chaos → Infrastructures → Select your K8s cluster → Copy ID

export TF_VAR_infra_ref="your-k8s-infrastructure-id"
```

### 2. Experiment Templates
The tests depend on experiment templates being created first. Ensure these templates exist:

**Custom Templates**:
- `harness_chaos_experiment_template.custom_fault_simple`
- `harness_chaos_experiment_template.custom_fault_with_action_probe`
- `harness_chaos_experiment_template.everything_custom`

**Enterprise Templates**:
- `harness_chaos_experiment_template.simple_fault_only`
- `harness_chaos_experiment_template.fault_with_probe_parallel`
- `harness_chaos_experiment_template.fault_with_two_probes`
- `harness_chaos_experiment_template.with_action`
- `harness_chaos_experiment_template.multi_fault`
- `harness_chaos_experiment_template.most_complex`
- `harness_chaos_experiment_template.account_level`
- `harness_chaos_experiment_template.org_level`
- `harness_chaos_experiment_template.project_level`

### 3. Required Variables

```hcl
# terraform.tfvars
org_id                = "default"
project_id            = "your-project-id"
hub_identity          = "your-custom-hub"
enterprise_hub_identity = "Enterprise ChaosHub"
infra_ref             = "your-k8s-infrastructure-id"  # REQUIRED!
```

## Running the Tests

### Enable Custom Template Tests

```bash
# Set the enable flag
export TF_VAR_enable_experiment_custom_templates_test=true

# Plan
terraform plan

# Apply
terraform apply -auto-approve

# Verify
terraform show | grep "harness_chaos_experiment.from_custom"
```

### Enable Enterprise Template Tests

```bash
# Set the enable flag
export TF_VAR_enable_experiment_enterprise_templates_test=true

# Plan
terraform plan

# Apply
terraform apply -auto-approve

# Verify
terraform show | grep "harness_chaos_experiment.from_enterprise"
```

### Run All Experiment Tests

```bash
# Enable both test suites
export TF_VAR_enable_experiment_custom_templates_test=true
export TF_VAR_enable_experiment_enterprise_templates_test=true

# Apply
terraform apply -auto-approve
```

## Test Scenarios Explained

### Scenario 1: Custom Templates
**Purpose**: Validate that experiments can be created from templates that use custom-built templates

**Flow**:
1. Custom fault/probe/action templates are created
2. Experiment templates reference these custom templates
3. Experiments are launched from these experiment templates
4. Infrastructure binding is applied at experiment creation

**Example**:
```
Custom Hub → Custom Fault Template → Experiment Template → Experiment (with infra binding)
```

### Scenario 2: Enterprise Templates
**Purpose**: Validate that experiments can be created from templates that use enterprise hub templates

**Flow**:
1. Enterprise hub provides pre-built fault/probe/action templates
2. Experiment templates reference enterprise templates
3. Experiments are launched from these experiment templates
4. Infrastructure binding is applied at experiment creation

**Example**:
```
Enterprise Hub → Enterprise Fault Template → Experiment Template → Experiment (with infra binding)
```

## Import Types: REFERENCE vs LOCAL ⭐ CRITICAL

### REFERENCE Import (Default)
**What it does**: Creates a reference to the experiment template

**Characteristics**:
- ✅ Template updates propagate to experiment
- ✅ Lightweight (no manifest copy)
- ✅ `template_details` populated in response
- ✅ `manifest` field is empty
- ✅ Recommended for most use cases

**Use when**: You want experiments to stay in sync with template changes

### LOCAL Import
**What it does**: Creates a full copy of the experiment template

**Characteristics**:
- ✅ Independent of template changes
- ✅ Full manifest stored
- ✅ `manifest` field populated with YAML
- ✅ `template_details` is null
- ✅ Experiment is portable

**Use when**: You want a snapshot that won't change when template is updated

### Example
```hcl
# REFERENCE import (default)
resource "harness_chaos_experiment" "ref" {
  template_identity = "my-template"
  import_type       = "REFERENCE"  # Template reference
  # ... other fields ...
}

# LOCAL import (full copy)
resource "harness_chaos_experiment" "local" {
  template_identity = "my-template"
  import_type       = "LOCAL"  # Full copy
  # ... other fields ...
}
```

---

## Key Differences: Templates vs Experiments

| Aspect | Experiment Template | Experiment |
|--------|-------------------|------------|
| **Purpose** | Reusable workflow definition | Runnable instance |
| **Infrastructure** | Not bound | MUST be bound |
| **Creation** | Direct creation | Created FROM template |
| **Updates** | Can be updated | Mostly immutable (ForceNew) |
| **Execution** | Cannot run | Can be executed |
| **Scope** | Account/Org/Project | Inherits from template |
| **Import Type** | N/A | REFERENCE or LOCAL |

## Hub Reference Formatting (Scope-Aware) ⭐ IMPORTANT

The provider automatically formats hub references based on scope:

| Scope | org_id | project_id | Hub Reference Format | Example |
|-------|--------|------------|---------------------|----------|
| **Account** | "" (empty) | "" (empty) | `account.{hub_identity}` | `account.enterprise-hub` |
| **Org** | "org123" | "" (empty) | `org.{hub_identity}` | `org.enterprise-hub` |
| **Project** | "org123" | "proj456" | `{hub_identity}` | `enterprise-hub` |

**You don't need to format this manually** - the provider handles it automatically!

```hcl
# Account-level experiment
resource "harness_chaos_experiment" "account" {
  org_id       = ""  # Empty for account
  project_id   = ""  # Empty for account
  hub_identity = "enterprise-hub"  # Provider adds "account." prefix
  # ...
}

# Org-level experiment
resource "harness_chaos_experiment" "org" {
  org_id       = "my-org"
  project_id   = ""  # Empty for org
  hub_identity = "enterprise-hub"  # Provider adds "org." prefix
  # ...
}

# Project-level experiment
resource "harness_chaos_experiment" "project" {
  org_id       = "my-org"
  project_id   = "my-project"
  hub_identity = "enterprise-hub"  # No prefix needed
  # ...
}
```

---

## Infrastructure Binding

**CRITICAL**: Experiments MUST have infrastructure binding at creation time!

```hcl
resource "harness_chaos_experiment" "example" {
  # ... other fields ...
  
  infra_ref = "prod-k8s-cluster"  # REQUIRED - cannot be empty
  
  # OR use runtime input
  infra_ref = "<+input>"  # User provides at runtime
}
```

## Testing Multiple Instances

Both test files include tests for creating multiple experiment instances from the same template:

```hcl
# Instance 1
resource "harness_chaos_experiment" "instance_1" {
  template_identity = harness_chaos_experiment_template.custom_fault_simple[0].identity
  name              = "Experiment-Instance-1-${random_string.suffix.result}"
  infra_ref         = var.infra_ref
}

# Instance 2
resource "harness_chaos_experiment" "instance_2" {
  template_identity = harness_chaos_experiment_template.custom_fault_simple[0].identity
  name              = "Experiment-Instance-2-${random_string.suffix.result}"
  infra_ref         = var.infra_ref
}
```

This validates that:
- ✅ Multiple experiments can be created from one template
- ✅ Each experiment is independent
- ✅ Each can have different infrastructure bindings
- ✅ Each can have different names/descriptions/tags

## Outputs

Each test file provides comprehensive outputs:

### Custom Templates Outputs
- `experiment_custom_fault_id`
- `experiment_custom_fault_identity`
- `experiment_custom_all_id`
- `experiment_everything_custom_id`
- `experiment_runtime_inputs_id`
- `experiment_instance_1_id`
- `experiment_instance_2_id`

### Enterprise Templates Outputs
- `experiment_enterprise_fault_id`
- `experiment_enterprise_fault_identity`
- `experiment_enterprise_parallel_id`
- `experiment_enterprise_two_probes_id`
- `experiment_enterprise_action_id`
- `experiment_enterprise_multi_fault_id`
- `experiment_enterprise_complex_id`
- `experiment_enterprise_account_level_id`
- `experiment_enterprise_org_level_id`
- `experiment_enterprise_project_level_id`
- `experiment_enterprise_instance_1_id`
- `experiment_enterprise_instance_2_id`
- `experiment_enterprise_instance_3_id`

## Verification

### Check Experiment Creation

```bash
# View all experiments
terraform output | grep experiment_

# Check specific experiment
terraform output experiment_custom_fault_id
```

### Verify in Harness UI

1. Navigate to **Chaos → Experiments**
2. Look for experiments with names matching pattern: `Experiment-*-<random_suffix>`
3. Verify:
   - ✅ Experiment is created
   - ✅ Infrastructure is bound
   - ✅ Template reference is correct
   - ✅ Tags are applied

### Run an Experiment

```bash
# Get experiment ID
EXPERIMENT_ID=$(terraform output -raw experiment_custom_fault_id)

# Run via Harness UI or API
# Chaos → Experiments → Select experiment → Run
```

## Cleanup

```bash
# Destroy all experiments
terraform destroy -target=harness_chaos_experiment.from_custom_fault
terraform destroy -target=harness_chaos_experiment.from_enterprise_fault

# Or destroy everything
terraform destroy -auto-approve
```

## Troubleshooting

### Error: "infra_ref is required"
**Solution**: Set the `infra_ref` variable to a valid Kubernetes infrastructure ID

```bash
export TF_VAR_infra_ref="your-k8s-infra-id"
```

### Error: "experiment template not found"
**Solution**: Ensure experiment templates are created first

```bash
# Enable experiment template tests first
export TF_VAR_enable_experiment_template_custom_fault_test=true
terraform apply -auto-approve

# Then enable experiment tests
export TF_VAR_enable_experiment_custom_templates_test=true
terraform apply -auto-approve
```

### Error: "hub not found"
**Solution**: Verify hub identity is correct

```bash
# List hubs
harness chaos hub list

# Update variable
export TF_VAR_hub_identity="correct-hub-identity"
```

## Best Practices

1. **Always bind infrastructure** - Never leave `infra_ref` empty
2. **Use runtime inputs** - For flexible infrastructure selection: `infra_ref = "<+input>"`
3. **Create templates first** - Experiments depend on experiment templates
4. **Use unique names** - Include random suffix to avoid conflicts
5. **Tag experiments** - Use tags for organization and filtering
6. **Test incrementally** - Enable one test suite at a time
7. **Clean up regularly** - Destroy test experiments to avoid clutter

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Chaos Hub                                │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ Custom Templates │  │Enterprise Templates│               │
│  │ - Faults         │  │ - Faults          │               │
│  │ - Probes         │  │ - Probes          │               │
│  │ - Actions        │  │ - Actions         │               │
│  └────────┬─────────┘  └────────┬──────────┘               │
└───────────┼────────────────────┼──────────────────────────┘
            │                    │
            ▼                    ▼
   ┌────────────────────────────────────────┐
   │      Experiment Templates              │
   │  - References templates                │
   │  - Defines workflow (vertices)         │
   │  - No infrastructure binding           │
   └──────────────┬─────────────────────────┘
                  │
                  ▼
         ┌────────────────────┐
         │    Experiments      │
         │ - Launched from     │
         │   templates         │
         │ - Infrastructure    │
         │   bound             │
         │ - Runnable          │
         └────────────────────┘
```

## Summary

These test files provide comprehensive coverage of:
- ✅ Experiments from custom templates (7 tests)
- ✅ Experiments from enterprise templates (13 tests)
- ✅ Multi-scope experiments (account/org/project)
- ✅ Multiple instances from same template
- ✅ Runtime input support
- ✅ Infrastructure binding validation

**Total Test Cases**: 27 experiments across 3 test files
- 7 custom template experiments
- 13 enterprise template experiments
- 7 import type & scope experiments

All tests follow Terraform best practices and validate the complete experiment lifecycle from template to runnable instance.
