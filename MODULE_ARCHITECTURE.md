# Module Architecture

## Visual Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                     Root Module (Orchestrator)                   │
│                                                                   │
│  • Composes all sub-modules                                      │
│  • Maintains backward compatibility                              │
│  • Exposes unified interface                                     │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ├─────────────────────────────────┐
                                 │                                 │
                                 ▼                                 ▼
┌────────────────────────────────────────┐    ┌──────────────────────────────┐
│      Foundation Module                 │    │    Chaos Hubs Module         │
│                                        │    │                              │
│  • Organization                        │    │  • Chaos Hub v1              │
│  • Project                             │    │  • Chaos Hub v2 (Account)    │
│  • K8s Connector                       │    │  • Chaos Hub v2 (Org)        │
│  • Git Connector                       │    │  • Chaos Hub v2 (Project)    │
│                                        │    │                              │
│  Outputs: org_id, project_id,          │    │  Outputs: hub IDs            │
│           connector_ids                │    │                              │
└────────────────────────────────────────┘    └──────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────┐
│      Infrastructure Module             │
│                                        │
│  • Environment                         │
│  • Platform Infrastructure             │
│                                        │
│  Outputs: environment_id,              │
│           infrastructure_id,           │
│           infra_ref                    │
└────────────────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────┐
│   Chaos Infrastructure Module          │
│                                        │
│  • Chaos Infrastructure V2             │
│  • Image Registry (Org)                │
│  • Image Registry (Project)            │
│                                        │
│  Outputs: chaos_infra_id,              │
│           registry_ids                 │
└────────────────────────────────────────┘
                  │
                  ├─────────────────────────────────┐
                  │                                 │
                  ▼                                 ▼
┌────────────────────────────────┐  ┌──────────────────────────────────┐
│  Service Discovery Module      │  │  Security Governance Module      │
│                                │  │                                  │
│  • SD Agent                    │  │  • Governance Condition          │
│                                │  │  • Governance Rule               │
│  Outputs: sd_agent_id          │  │                                  │
│                                │  │  Outputs: condition_id, rule_id  │
└────────────────────────────────┘  └──────────────────────────────────┘
```

## Dependency Flow

```
┌──────────────┐
│  Foundation  │
└──────┬───────┘
       │
       ├────────────────────────────┐
       │                            │
       ▼                            ▼
┌──────────────┐            ┌─────────────┐
│Infrastructure│            │ Chaos Hubs  │
└──────┬───────┘            └─────────────┘
       │                    (Independent)
       ▼
┌──────────────────┐
│Chaos             │
│Infrastructure    │
└──────┬───────────┘
       │
       ├────────────────────┐
       │                    │
       ▼                    ▼
┌──────────────┐    ┌──────────────────┐
│   Service    │    │    Security      │
│  Discovery   │    │   Governance     │
└──────────────┘    └──────────────────┘
```

## Module Interfaces

### Foundation Module

**Inputs**:
```hcl
variable "create_organization" { type = bool }
variable "create_project" { type = bool }
variable "create_k8s_connector" { type = bool }
variable "create_git_connector" { type = bool }

variable "org_identifier" { type = string }
variable "org_name" { type = string }
variable "project_identifier" { type = string }
variable "project_name" { type = string }

variable "k8s_connector_name" { type = string }
variable "delegate_selectors" { type = list(string) }

variable "git_connector_name" { type = string }
variable "git_connector_url" { type = string }
# ... other git connector configs
```

**Outputs**:
```hcl
output "org_id" { value = local.org_id }
output "project_id" { value = local.project_id }
output "k8s_connector_id" { value = local.k8s_connector_id }
output "git_connector_id" { value = local.git_connector_id }
```

### Infrastructure Module

**Inputs**:
```hcl
variable "org_id" { type = string }
variable "project_id" { type = string }
variable "k8s_connector_id" { type = string }

variable "environment_identifier" { type = string }
variable "environment_name" { type = string }
variable "infrastructure_identifier" { type = string }
variable "infrastructure_name" { type = string }
variable "namespace" { type = string }
variable "deployment_type" { type = string }
```

**Outputs**:
```hcl
output "environment_id" { value = harness_platform_environment.this.id }
output "infrastructure_id" { value = harness_platform_infrastructure.this.id }
output "infra_ref" { value = "${harness_platform_environment.this.id}/${harness_platform_infrastructure.this.id}" }
```

### Chaos Infrastructure Module

**Inputs**:
```hcl
variable "org_id" { type = string }
variable "project_id" { type = string }
variable "environment_id" { type = string }
variable "infrastructure_id" { type = string }

variable "create_chaos_infrastructure" { type = bool }
variable "setup_custom_registry" { type = bool }

variable "chaos_infra_name" { type = string }
variable "infra_id" { type = string }
variable "namespace" { type = string }
variable "service_account" { type = string }

variable "registry_server" { type = string }
variable "registry_account" { type = string }
# ... other registry configs
```

**Outputs**:
```hcl
output "chaos_infrastructure_id" { value = harness_chaos_infrastructure_v2.this[0].id }
output "chaos_infrastructure_identity" { value = harness_chaos_infrastructure_v2.this[0].identity }
output "image_registry_org_id" { value = harness_chaos_image_registry.org_level[0].id }
output "image_registry_project_id" { value = harness_chaos_image_registry.project_level[0].id }
```

### Service Discovery Module

**Inputs**:
```hcl
variable "org_id" { type = string }
variable "project_id" { type = string }
variable "environment_id" { type = string }
variable "infrastructure_id" { type = string }

variable "sd_agent_name" { type = string }
variable "sd_installation_type" { type = string }
variable "sd_namespace" { type = string }
variable "correlation_id" { type = string }
variable "sd_run_as_user" { type = number }
variable "sd_run_as_group" { type = number }
```

**Outputs**:
```hcl
output "sd_agent_id" { value = harness_service_discovery_agent.this.id }
output "sd_agent_name" { value = harness_service_discovery_agent.this.name }
```

### Chaos Hubs Module

**Inputs**:
```hcl
variable "org_id" { type = string }
variable "project_id" { type = string }
variable "git_connector_id" { type = string }

variable "create_chaos_hub" { type = bool }
variable "create_chaos_hub_v2_account_level" { type = bool }
variable "create_chaos_hub_v2_org_level" { type = bool }
variable "create_chaos_hub_v2_project_level" { type = bool }

variable "chaos_hub_name" { type = string }
variable "chaos_hub_repo_url" { type = string }
variable "chaos_hub_repo_branch" { type = string }

variable "chaos_hub_v2_account_identity" { type = string }
variable "chaos_hub_v2_account_name" { type = string }
# ... other hub configs
```

**Outputs**:
```hcl
output "chaos_hub_id" { value = harness_chaos_hub.this[0].id }
output "chaos_hub_v2_account_id" { value = harness_chaos_hub_v2.account_level[0].id }
output "chaos_hub_v2_org_id" { value = harness_chaos_hub_v2.org_level[0].id }
output "chaos_hub_v2_project_id" { value = harness_chaos_hub_v2.project_level[0].id }
```

### Security Governance Module

**Inputs**:
```hcl
variable "org_id" { type = string }
variable "project_id" { type = string }
variable "environment_id" { type = string }
variable "chaos_infrastructure_id" { type = string }

variable "create_condition" { type = bool }
variable "create_rule" { type = bool }

variable "condition_name" { type = string }
variable "condition_infra_type" { type = string }
variable "condition_operator" { type = string }
variable "condition_faults" { type = list(object) }

variable "rule_name" { type = string }
variable "rule_description" { type = string }
variable "rule_is_enabled" { type = bool }
variable "rule_user_group_ids" { type = list(string) }
variable "rule_time_windows" { type = list(object) }
```

**Outputs**:
```hcl
output "condition_id" { value = harness_chaos_security_governance_condition.this[0].id }
output "rule_id" { value = harness_chaos_security_governance_rule.this[0].id }
```

## Testing Architecture

```
tests/
├── foundation/
│   ├── main.tf              # Test foundation module in isolation
│   ├── variables.tf
│   └── terraform.tfvars
│
├── infrastructure/
│   ├── main.tf              # Test with mock foundation outputs
│   ├── variables.tf
│   └── terraform.tfvars
│
├── chaos-infrastructure/
│   ├── main.tf              # Test with mock infrastructure outputs
│   ├── variables.tf
│   └── terraform.tfvars
│
├── service-discovery/
│   ├── main.tf              # Test with mock chaos infra outputs
│   ├── variables.tf
│   └── terraform.tfvars
│
├── chaos-hubs/
│   ├── main.tf              # Test with mock foundation outputs
│   ├── variables.tf
│   └── terraform.tfvars
│
├── security-governance/
│   ├── main.tf              # Test with mock chaos infra outputs
│   ├── variables.tf
│   └── terraform.tfvars
│
└── integration/
    ├── main.tf              # Test full module composition
    ├── variables.tf
    └── terraform.tfvars
```

## Example: Testing Foundation Module in Isolation

```hcl
# tests/foundation/main.tf

module "foundation" {
  source = "../../modules/foundation"
  
  # Test creating everything
  create_organization  = true
  create_project       = true
  create_k8s_connector = true
  create_git_connector = true
  
  org_name     = "Test Organization"
  project_name = "Test Project"
  
  k8s_connector_name = "test-k8s-connector"
  delegate_selectors = ["test-delegate"]
  
  git_connector_name = "test-git-connector"
  git_connector_url  = "https://github.com/test/repo"
  
  tags = {
    "test" = "foundation"
  }
}

output "org_id" {
  value = module.foundation.org_id
}

output "project_id" {
  value = module.foundation.project_id
}

output "k8s_connector_id" {
  value = module.foundation.k8s_connector_id
}
```

## Example: Testing Infrastructure Module with Mock Inputs

```hcl
# tests/infrastructure/main.tf

# Mock foundation outputs
locals {
  org_id           = "test-org"
  project_id       = "test-project"
  k8s_connector_id = "test-k8s-connector"
}

module "infrastructure" {
  source = "../../modules/infrastructure"
  
  org_id           = local.org_id
  project_id       = local.project_id
  k8s_connector_id = local.k8s_connector_id
  
  environment_identifier    = "test-env"
  environment_name          = "Test Environment"
  infrastructure_identifier = "test-infra"
  infrastructure_name       = "Test Infrastructure"
  namespace                 = "test-namespace"
  deployment_type           = "Kubernetes"
  
  tags = {
    "test" = "infrastructure"
  }
}

output "environment_id" {
  value = module.infrastructure.environment_id
}

output "infrastructure_id" {
  value = module.infrastructure.infrastructure_id
}

output "infra_ref" {
  value = module.infrastructure.infra_ref
}
```

## CI/CD Integration

```yaml
# .github/workflows/test-modules.yml

name: Test Modules

on: [push, pull_request]

jobs:
  test-foundation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v2
      - name: Test Foundation Module
        run: |
          cd tests/foundation
          terraform init
          terraform validate
          terraform plan

  test-infrastructure:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v2
      - name: Test Infrastructure Module
        run: |
          cd tests/infrastructure
          terraform init
          terraform validate
          terraform plan

  test-chaos-infrastructure:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v2
      - name: Test Chaos Infrastructure Module
        run: |
          cd tests/chaos-infrastructure
          terraform init
          terraform validate
          terraform plan

  # ... other module tests

  test-integration:
    runs-on: ubuntu-latest
    needs: [test-foundation, test-infrastructure, test-chaos-infrastructure]
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v2
      - name: Test Full Integration
        run: |
          cd tests/integration
          terraform init
          terraform validate
          terraform plan
```

## Benefits Summary

### 1. Isolated Testing ✅
- Each module can be tested independently
- Mock inputs for dependencies
- Faster test cycles
- Easier debugging

### 2. Clear Boundaries ✅
- Each module has single responsibility
- Explicit dependencies
- Clear input/output contracts
- Better encapsulation

### 3. Reusability ✅
- Modules can be used independently
- Mix and match as needed
- Share modules across projects
- Publish to Terraform Registry

### 4. Maintainability ✅
- Smaller, focused files
- Easier to understand
- Easier to modify
- Better code organization

### 5. Scalability ✅
- Add new modules easily
- Extend existing modules
- Version modules independently
- Parallel development

## Migration Path

### Step 1: Create Module Structure
```bash
mkdir -p modules/{foundation,infrastructure,chaos-infrastructure,service-discovery,chaos-hubs,security-governance}
```

### Step 2: Extract Resources
```bash
# Move resources to appropriate modules
# Update references
# Test each module
```

### Step 3: Update Root Module
```bash
# Update main.tf to use modules
# Keep variables.tf and outputs.tf at root
# Test backward compatibility
```

### Step 4: Add Tests
```bash
mkdir -p tests/{foundation,infrastructure,chaos-infrastructure,service-discovery,chaos-hubs,security-governance,integration}
# Add test configurations
```

### Step 5: Verify
```bash
# Run all tests
# Verify backward compatibility
# Update documentation
```

## Conclusion

This modular architecture provides:
- ✅ **Isolated testing** of each component
- ✅ **Clear separation** of concerns
- ✅ **Easy maintenance** with smaller files
- ✅ **Backward compatibility** with existing code
- ✅ **Production ready** structure

Ready to implement! 🚀
