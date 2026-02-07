# Main Module vs E2E Test - Design Comparison

## Summary: Different Design Philosophies

The main module and e2e-test have fundamentally different design approaches:

- **Main Module**: Flexible, feature-flag driven, production-ready
- **E2E Test**: Comprehensive, all-inclusive, testing-focused

## Key Differences

### 1. Feature Flags

**Main Module**: Uses feature flags to control resource creation
```hcl
# terraform.tfvars (main module)
create_k8s_connector                    = false
create_sd_agent                         = false
create_git_connector                    = false
create_security_governance_condition    = false
create_security_governance_rule         = false
create_chaos_hub                        = true
create_chaos_hub_v2_account_level       = true
create_chaos_hub_v2_org_level           = true
create_chaos_hub_v2_project_level       = true
setup_custom_registry_project_level     = true
setup_custom_registry_org_level         = true
```

**E2E Test**: No feature flags - creates everything
```hcl
# No feature flags - all resources created by default
```

**Why**: Main module is designed for production where users may want to:
- Use existing connectors
- Skip security governance
- Choose which hubs to create
- Selectively enable features

E2E test is designed to test **all features** comprehensively.

### 2. Resource Creation Strategy

**Main Module**: Conditional resource creation
```hcl
# Example from main.tf
resource "harness_platform_connector_kubernetes" "this" {
  count = var.create_k8s_connector ? 1 : 0
  # ...
}

resource "harness_service_discovery_agent" "this" {
  count = var.create_sd_agent ? 1 : 0
  # ...
}

resource "harness_chaos_security_governance_condition" "this" {
  count = var.create_security_governance_condition ? 1 : 0
  # ...
}
```

**E2E Test**: Direct resource creation
```hcl
# Example from e2e-test
resource "harness_platform_connector_kubernetes" "this" {
  # Always created - no count
}

resource "harness_service_discovery_agent" "this" {
  # Always created - no count
}

resource "harness_chaos_security_governance_condition" "this" {
  # Always created - no count
}
```

### 3. Scope Configuration

**Main Module**: Uses locals for scope
```hcl
# main.tf
locals {
  org_id     = var.org_identifier
  project_id = var.project_identifier
}

# Can use existing org/project
org_identifier     = "default"
project_identifier = "ChaosDevProd1"
```

**E2E Test**: Creates its own org/project
```hcl
# 01-foundation.tf
resource "harness_platform_organization" "this" {
  identifier = var.organization_identifier
  name       = var.organization_name
}

resource "harness_platform_project" "this" {
  identifier = var.project_identifier
  name       = var.project_name
  org_id     = harness_platform_organization.this.id
}
```

**Why**: Main module assumes existing org/project (production scenario). E2E test creates isolated environment for testing.

### 4. Connector Strategy

**Main Module**: Uses existing connectors
```hcl
# terraform.tfvars
create_k8s_connector = false
create_git_connector = false

# Uses pre-configured connectors
chaos_hub_connector_id    = "accountlevelchaoshubtf"
chaos_hub_connector_scope = "ACCOUNT"
```

**E2E Test**: Creates all connectors
```hcl
# 01-foundation.tf
resource "harness_platform_connector_kubernetes" "this" {
  # Creates new K8s connector
}

# 02-chaos-hubs.tf
# Uses inline Git configuration (no separate connector)
```

### 5. Variable Defaults

**Main Module**: Minimal defaults (expects user configuration)
```hcl
variable "create_k8s_connector" {
  description = "Whether to create a Kubernetes connector"
  type        = bool
  default     = false  # Don't create by default
}

variable "org_identifier" {
  description = "Organization identifier"
  type        = string
  # No default - user must provide
}
```

**E2E Test**: Comprehensive defaults (ready to run)
```hcl
variable "organization_identifier" {
  description = "Organization identifier"
  type        = string
  default     = "chaos_e2e_org"  # Has default
}

variable "chaos_hub_tags" {
  description = "Tags for chaos hubs"
  type        = list(string)
  default     = ["e2e", "test", "chaos-hub"]  # Has default
}
```

### 6. Security Governance

**Main Module**: Optional with detailed configuration
```hcl
create_security_governance_condition = false
create_security_governance_rule      = false

# Detailed application spec
security_governance_condition_application_spec = {
  operator = "EQUAL_TO"
  workloads = [
    {
      namespace          = "harness-tf-11"
      kind               = "deployment"
      label              = "app=boutique"
      services           = ["boutique"]
      application_map_id = "boutique-app"
    }
  ]
}
```

**E2E Test**: Always created with simple configuration
```hcl
# Always creates security governance
# Simpler configuration for testing
application_spec {
  operator = "IN"
  workloads {
    namespace = var.namespace
    kind      = "deployment"
  }
}
```

### 7. Chaos Hubs

**Main Module**: Selective hub creation
```hcl
create_chaos_hub_v2_account_level = true
create_chaos_hub_v2_org_level     = true
create_chaos_hub_v2_project_level = true

# Can enable/disable each level independently
```

**E2E Test**: All hubs created
```hcl
# Always creates all 3 levels
resource "harness_chaos_hub_v2" "account_level" { }
resource "harness_chaos_hub_v2" "org_level" { }
resource "harness_chaos_hub_v2" "project_level" { }
```

### 8. Templates

**Main Module**: Conditional template creation
```hcl
# Likely has feature flags for templates
# (not shown in the snippet but expected pattern)
```

**E2E Test**: Comprehensive template coverage
```hcl
# Creates 15 templates:
# - 3 Action Templates (account, org, project)
# - 3 Probe Templates (account, org, project)
# - 3 Fault Templates (account, org, project)
# - 6 Experiment Templates (2 per level: custom + enterprise)
```

### 9. Experiments

**Main Module**: Likely optional
```hcl
# Experiments probably controlled by feature flags
```

**E2E Test**: Creates 6 experiments
```hcl
# 6 experiments (3 REFERENCE + 3 LOCAL)
# - Account level: custom + enterprise
# - Org level: custom + enterprise
# - Project level: custom + enterprise
```

## Design Philosophy Comparison

| Aspect | Main Module | E2E Test |
|--------|-------------|----------|
| **Purpose** | Production deployment | Comprehensive testing |
| **Flexibility** | High (feature flags) | Low (fixed structure) |
| **Resource Creation** | Selective | All-inclusive |
| **Scope** | Uses existing org/project | Creates isolated environment |
| **Connectors** | Uses existing | Creates new |
| **Defaults** | Minimal | Comprehensive |
| **Configuration** | User-driven | Test-driven |
| **Complexity** | Higher (more options) | Lower (straightforward) |
| **Use Case** | Production environments | CI/CD testing |

## When to Use Each

### Use Main Module When:
- ✅ Deploying to production
- ✅ Need selective feature enablement
- ✅ Using existing infrastructure (org, project, connectors)
- ✅ Want fine-grained control
- ✅ Need to integrate with existing Harness setup

### Use E2E Test When:
- ✅ Testing all features
- ✅ Need isolated test environment
- ✅ Running CI/CD validation
- ✅ Demonstrating capabilities
- ✅ Learning the module

## Feature Flag Pattern (Main Module)

The main module uses a consistent pattern for optional resources:

```hcl
# 1. Define feature flag variable
variable "create_resource" {
  type    = bool
  default = false
}

# 2. Conditional resource creation
resource "harness_resource" "this" {
  count = var.create_resource ? 1 : 0
  # ...
}

# 3. Reference with index
resource "dependent_resource" "this" {
  resource_id = var.create_resource ? harness_resource.this[0].id : var.existing_resource_id
}
```

## E2E Test Pattern

The e2e-test uses a straightforward pattern:

```hcl
# 1. Create foundation
resource "harness_platform_organization" "this" { }
resource "harness_platform_project" "this" { }

# 2. Create all resources
resource "harness_chaos_hub_v2" "account_level" { }
resource "harness_chaos_hub_v2" "org_level" { }
resource "harness_chaos_hub_v2" "project_level" { }

# 3. Direct references (no conditionals)
resource "harness_chaos_experiment" "example" {
  hub_identity = harness_chaos_hub_v2.project_level.identity
}
```

## Migration Path

### From E2E Test to Main Module

If you want to use main module patterns in e2e-test:

1. Add feature flag variables
2. Add `count` to resources
3. Add conditional logic for references
4. Update outputs to handle optional resources

**Not recommended** - E2E test should remain comprehensive for testing.

### From Main Module to E2E Test

If you want to simplify main module:

1. Remove feature flags
2. Remove `count` from resources
3. Simplify references
4. Add comprehensive defaults

**Not recommended** - Main module should remain flexible for production.

## Conclusion

✅ **Both designs are correct for their purposes**

- **Main Module**: Production-ready, flexible, feature-flag driven
- **E2E Test**: Testing-focused, comprehensive, straightforward

The e2e-test should **NOT** copy the feature flag pattern from main.tf. It should remain a comprehensive test suite that creates all resources to validate the entire module.

## Recommendation

✅ **Keep the designs separate**

- Main module: Continue with feature flags for production flexibility
- E2E test: Continue creating all resources for comprehensive testing

This separation of concerns is a **best practice** in Terraform module development.
