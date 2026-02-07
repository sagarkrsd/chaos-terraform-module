# Configuration Files Comparison

## Summary

Comparison of configuration files between main module and e2e-test directory.

| File | Main Module | E2E Test | Status | Notes |
|------|-------------|----------|--------|-------|
| providers.tf | ✅ Yes | ✅ Yes | ✅ FIXED | Now matches main module pattern |
| version.tf | ❌ No | ✅ Yes | ✅ OK | E2E has version constraints |
| variables.tf | ✅ Yes (182) | ✅ Yes (54) | ✅ OK | E2E has focused subset |
| outputs.tf | ✅ Yes (15) | ✅ Yes (40) | ✅ OK | E2E has comprehensive outputs |
| terraform.tfvars.example | ❌ No | ✅ Yes | ✅ OK | E2E provides example |

## 1. providers.tf

### Main Module Pattern
```hcl
variable "harness_endpoint" {
  type        = string
  description = "Harness endpoint"
  default     = "https://app.harness.io/gateway"
}

variable "harness_account_id" {
  type        = string
  description = "Harness account ID"
}

variable "harness_platform_api_key" {
  type        = string
  description = "Harness platform API key"
  sensitive   = true
}

provider "harness" {
  endpoint         = var.harness_endpoint
  account_id       = var.harness_account_id
  platform_api_key = var.harness_platform_api_key
}
```

### E2E Test (After Fix)
```hcl
variable "harness_endpoint" {
  type        = string
  description = "Harness endpoint"
  default     = "https://app.harness.io/gateway"
}

variable "harness_account_id" {
  type        = string
  description = "Harness account ID"
}

variable "harness_platform_api_key" {
  type        = string
  description = "Harness platform API key"
  sensitive   = true
}

provider "harness" {
  endpoint         = var.harness_endpoint
  account_id       = var.harness_account_id
  platform_api_key = var.harness_platform_api_key
}
```

**Status**: ✅ MATCHES (after fix)

**Changes Applied**:
- Removed duplicate `required_providers` block (already in version.tf)
- Changed from environment variable pattern to explicit variable pattern
- Now matches main module exactly

## 2. version.tf

### Main Module
❌ Does not exist

### E2E Test
```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    harness = {
      source  = "harness/harness"
      version = "~> 0.30"
    }
  }
}
```

**Status**: ✅ OK - E2E test has version constraints (best practice)

**Rationale**: E2E test is a standalone module, so it needs version constraints. Main module may be used as a module by others, so version constraints are optional.

## 3. variables.tf

### Main Module
- **Count**: 182 variables
- **Purpose**: Supports all test cases (action templates, probe templates, fault templates, experiment templates, experiments, etc.)
- **Scope**: Comprehensive for all scenarios

### E2E Test
- **Count**: 54 variables
- **Purpose**: Focused on e2e test scenario only
- **Scope**: Subset of main module variables

### Variable Categories Comparison

| Category | Main Module | E2E Test | Status |
|----------|-------------|----------|--------|
| Foundation | ✅ Yes | ✅ Yes | ✅ Match |
| Connectors | ✅ Yes | ✅ Yes | ✅ Match |
| Chaos Hubs | ✅ Yes | ✅ Yes | ✅ Match |
| Infrastructure | ✅ Yes | ✅ Yes | ✅ Match |
| Service Discovery | ✅ Yes | ✅ Yes | ✅ Match |
| Image Registry | ✅ Yes | ✅ Yes | ✅ Match |
| Security Governance | ✅ Yes | ✅ Yes | ✅ Match |
| Action Templates | ✅ Many | ❌ No | ✅ OK (hardcoded in resources) |
| Probe Templates | ✅ Many | ❌ No | ✅ OK (hardcoded in resources) |
| Fault Templates | ✅ Many | ❌ No | ✅ OK (hardcoded in resources) |
| Experiment Templates | ✅ Many | ❌ No | ✅ OK (hardcoded in resources) |
| Experiments | ✅ Many | ❌ No | ✅ OK (hardcoded in resources) |
| Common Tags | ✅ Yes | ✅ Yes | ✅ Match |

**Status**: ✅ OK - E2E test has appropriate subset

**Rationale**: 
- Main module variables support parameterization of all test cases
- E2E test hardcodes template configurations in resource definitions
- E2E test focuses on infrastructure and foundation variables
- Both approaches are valid

### Key Variables Present in Both

**Foundation** (✅ Match):
- org_identifier, org_name
- project_identifier, project_name, project_color

**Connectors** (✅ Match):
- k8s_connector_identifier, k8s_connector_name
- delegate_selectors

**Infrastructure** (✅ Match):
- environment_identifier, environment_name
- infrastructure_identifier, infrastructure_name
- deployment_type, namespace

**Chaos Infrastructure** (✅ Match):
- chaos_infra_identity, chaos_infra_name
- chaos_service_account

**Service Discovery** (✅ Match):
- sd_installation_type
- service_discovery_agent_name
- sd_namespace

**Image Registry** (✅ Match):
- setup_custom_registry
- registry_server, registry_account
- is_default_registry, is_override_allowed, is_private_registry
- use_custom_images
- log_watcher_image, ddcr_image, ddcr_lib_image, ddcr_fault_image

**Security Governance** (✅ Match):
- security_governance_condition_name
- security_governance_rule_name
- security_governance_rule_user_group_ids

**Common Tags** (✅ Match):
- common_tags variable

## 4. outputs.tf

### Main Module
- **Count**: 15 outputs
- **Focus**: Core infrastructure resources
- **Outputs**:
  - organization_id
  - project_id
  - environment_id
  - kubernetes_connector_id
  - infrastructure_id
  - org_chaos_image_registry_id
  - project_chaos_image_registry_id
  - chaos_infrastructure_id
  - service_discovery_agent_id
  - chaos_hub_id
  - security_governance_condition_id
  - security_governance_rule_id
  - chaos_hub_v2_account_level_id
  - chaos_hub_v2_org_level_id
  - chaos_hub_v2_project_level_id

### E2E Test
- **Count**: 40 outputs
- **Focus**: Comprehensive coverage of all resources
- **Outputs**:
  - Foundation (2): org_id, project_id
  - Chaos Hubs (3): account, org, project
  - Action Templates (3): account, org, project
  - Probe Templates (3): account, org, project
  - Fault Templates (3): account, org, project
  - Experiment Templates (6): account custom/enterprise, org custom/enterprise, project custom/enterprise
  - Infrastructure (4): environment, platform infra, chaos infra, SD agent
  - Security Governance (2): condition, rule
  - Experiments (6): account custom/enterprise, org custom/enterprise, project custom/enterprise
  - Image Registry (1): project level
  - Summary (1): aggregated output with all key IDs

**Status**: ✅ OK - E2E test has more comprehensive outputs

**Rationale**:
- E2E test outputs cover all 34 resources created
- Main module outputs focus on core infrastructure
- E2E test includes summary output for easy reference
- Both are appropriate for their use cases

### Output Comparison

| Output Category | Main Module | E2E Test | Status |
|----------------|-------------|----------|--------|
| Foundation | ✅ Yes | ✅ Yes | ✅ Match |
| Chaos Hubs | ✅ Yes (3) | ✅ Yes (3) | ✅ Match |
| Infrastructure | ✅ Yes | ✅ Yes | ✅ Match |
| Security Governance | ✅ Yes | ✅ Yes | ✅ Match |
| Templates | ❌ No | ✅ Yes (15) | ✅ OK (E2E more comprehensive) |
| Experiments | ❌ No | ✅ Yes (6) | ✅ OK (E2E more comprehensive) |
| Summary | ❌ No | ✅ Yes | ✅ OK (E2E provides aggregated view) |

## 5. terraform.tfvars.example

### Main Module
❌ Does not exist

### E2E Test
✅ Exists with comprehensive example values

**Content**:
- Provider configuration examples
- Foundation configuration
- Connector configuration
- Chaos hub configuration
- Infrastructure configuration
- Service discovery configuration
- Image registry configuration (optional)
- Security governance configuration
- Common tags

**Status**: ✅ OK - E2E test provides helpful example

**Rationale**: E2E test is designed to be run standalone, so example tfvars file helps users get started quickly.

## Configuration File Best Practices

### ✅ E2E Test Follows Best Practices

1. **Version Constraints** - Has version.tf with Terraform and provider version constraints
2. **Provider Configuration** - Explicit variable-based configuration (matches main module)
3. **Example Values** - Provides terraform.tfvars.example for easy setup
4. **Comprehensive Outputs** - 40 outputs covering all resources
5. **Focused Variables** - 54 variables focused on e2e scenario
6. **Documentation** - Well-documented with comments

### Main Module Characteristics

1. **Flexible** - 182 variables support many test scenarios
2. **Core Outputs** - 15 outputs for essential resources
3. **Provider Variables** - Explicit configuration (not environment variables)
4. **No Version Constraints** - Allows flexibility when used as module

## Summary

| Aspect | Status | Notes |
|--------|--------|-------|
| providers.tf | ✅ FIXED | Now matches main module pattern |
| version.tf | ✅ OK | E2E has constraints (best practice) |
| variables.tf | ✅ OK | E2E has focused subset (54 vs 182) |
| outputs.tf | ✅ OK | E2E more comprehensive (40 vs 15) |
| terraform.tfvars.example | ✅ OK | E2E provides example (main doesn't) |

## Recommendations

### ✅ No Changes Needed

All configuration files are appropriate for their use cases:

1. **providers.tf** - ✅ Fixed to match main module
2. **version.tf** - ✅ E2E has version constraints (good practice)
3. **variables.tf** - ✅ E2E has appropriate subset
4. **outputs.tf** - ✅ E2E has comprehensive outputs
5. **terraform.tfvars.example** - ✅ E2E provides helpful example

### Configuration Files Ready for Use

All configuration files have been reviewed and verified:
- ✅ Provider configuration matches main module
- ✅ Version constraints in place
- ✅ Variables cover all required resources
- ✅ Outputs provide comprehensive visibility
- ✅ Example tfvars file helps with setup

## Next Steps

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update with your actual Harness credentials and configuration
3. Run `terraform init` to initialize
4. Run `terraform plan` to verify configuration
5. Run `terraform apply` to create all 34 resources
