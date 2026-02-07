# Main Module Restructuring Plan

## Objective

Reorganize the main module to:
1. ✅ Enable isolated testing of each component
2. ✅ Improve maintainability through clear separation
3. ✅ Follow Terraform best practices
4. ✅ Maintain backward compatibility

## Current Structure (Single File)

```
chaos-terraform-module/
├── main.tf                    # 535 lines - ALL resources
├── variables.tf               # All variables
├── outputs.tf                 # All outputs
├── providers.tf               # Provider configuration
├── versions.tf                # Version constraints
└── terraform.tfvars          # Example values
```

**Problems**:
- ❌ Hard to test individual components
- ❌ Difficult to maintain (535 lines in one file)
- ❌ No clear separation of concerns
- ❌ Hard to understand dependencies

## Proposed Structure (Modular)

```
chaos-terraform-module/
├── main.tf                    # Module composition (orchestration)
├── locals.tf                  # Local values and computed references
├── variables.tf               # All input variables
├── outputs.tf                 # All outputs
├── providers.tf               # Provider configuration
├── versions.tf                # Version constraints
├── terraform.tfvars.example   # Example values
│
├── modules/                   # Reusable sub-modules
│   ├── foundation/            # Organization, Project, Connectors
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── infrastructure/        # Environment, Infrastructure, K8s
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── chaos-infrastructure/  # Chaos Infra V2, Image Registry
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── service-discovery/     # Service Discovery Agent
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── chaos-hubs/            # Chaos Hubs (v1 and v2)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── security-governance/   # Security Governance
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── examples/                  # Usage examples
│   ├── minimal/               # Minimal setup
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars.example
│   │
│   ├── complete/              # Full setup
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars.example
│   │
│   └── existing-resources/    # Using existing resources
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars.example
│
└── tests/                     # Isolated component tests
    ├── foundation/
    │   ├── main.tf
    │   └── terraform.tfvars
    │
    ├── infrastructure/
    │   ├── main.tf
    │   └── terraform.tfvars
    │
    ├── chaos-infrastructure/
    │   ├── main.tf
    │   └── terraform.tfvars
    │
    ├── service-discovery/
    │   ├── main.tf
    │   └── terraform.tfvars
    │
    ├── chaos-hubs/
    │   ├── main.tf
    │   └── terraform.tfvars
    │
    └── security-governance/
        ├── main.tf
        └── terraform.tfvars
```

## Module Breakdown

### 1. Foundation Module

**Purpose**: Create organization, project, and connectors

**Resources**:
- `harness_platform_organization`
- `harness_platform_project`
- `harness_platform_connector_kubernetes`
- `harness_platform_connector_git`

**Inputs**:
- `create_organization`
- `create_project`
- `create_k8s_connector`
- `create_git_connector`
- Organization/project details
- Connector configurations

**Outputs**:
- `org_id`
- `project_id`
- `k8s_connector_id`
- `git_connector_id`

**Test Isolation**: Can be tested independently

### 2. Infrastructure Module

**Purpose**: Create environment and platform infrastructure

**Resources**:
- `harness_platform_environment`
- `harness_platform_infrastructure`

**Inputs**:
- `org_id` (from foundation or provided)
- `project_id` (from foundation or provided)
- `k8s_connector_id` (from foundation or provided)
- Environment/infrastructure details

**Outputs**:
- `environment_id`
- `infrastructure_id`
- `infra_ref` (computed: env_id/infra_id)

**Test Isolation**: Can be tested with mock foundation outputs

### 3. Chaos Infrastructure Module

**Purpose**: Create chaos infrastructure and image registry

**Resources**:
- `harness_chaos_infrastructure_v2`
- `harness_chaos_image_registry` (org level)
- `harness_chaos_image_registry` (project level)

**Inputs**:
- `org_id`
- `project_id`
- `environment_id`
- `infrastructure_id`
- `create_chaos_infrastructure`
- `setup_custom_registry`
- Registry configurations

**Outputs**:
- `chaos_infrastructure_id`
- `chaos_infrastructure_identity`
- `image_registry_org_id`
- `image_registry_project_id`

**Test Isolation**: Can be tested with mock infrastructure outputs

### 4. Service Discovery Module

**Purpose**: Create service discovery agent

**Resources**:
- `harness_service_discovery_agent`

**Inputs**:
- `org_id`
- `project_id`
- `environment_id`
- `infrastructure_id`
- `create_sd_agent`
- SD agent configurations

**Outputs**:
- `sd_agent_id`
- `sd_agent_name`

**Test Isolation**: Can be tested with mock chaos infrastructure outputs

### 5. Chaos Hubs Module

**Purpose**: Create chaos hubs at all levels

**Resources**:
- `harness_chaos_hub` (v1)
- `harness_chaos_hub_v2` (account level)
- `harness_chaos_hub_v2` (org level)
- `harness_chaos_hub_v2` (project level)

**Inputs**:
- `org_id`
- `project_id`
- `git_connector_id` (for v1)
- `create_chaos_hub`
- `create_chaos_hub_v2_account_level`
- `create_chaos_hub_v2_org_level`
- `create_chaos_hub_v2_project_level`
- Hub configurations

**Outputs**:
- `chaos_hub_id`
- `chaos_hub_v2_account_id`
- `chaos_hub_v2_org_id`
- `chaos_hub_v2_project_id`

**Test Isolation**: Can be tested with mock foundation outputs

### 6. Security Governance Module

**Purpose**: Create security governance rules and conditions

**Resources**:
- `harness_chaos_security_governance_condition`
- `harness_chaos_security_governance_rule`

**Inputs**:
- `org_id`
- `project_id`
- `environment_id`
- `chaos_infrastructure_id`
- `create_security_governance_condition`
- `create_security_governance_rule`
- Governance configurations

**Outputs**:
- `security_governance_condition_id`
- `security_governance_rule_id`

**Test Isolation**: Can be tested with mock chaos infrastructure outputs

## Root Module Composition

The root `main.tf` orchestrates all sub-modules:

```hcl
# main.tf (root module)

# 1. Foundation
module "foundation" {
  source = "./modules/foundation"
  
  create_organization  = var.create_organization
  create_project       = var.create_project
  create_k8s_connector = var.create_k8s_connector
  create_git_connector = var.create_git_connector
  
  org_identifier     = var.org_identifier
  org_name           = var.org_name
  project_identifier = var.project_identifier
  project_name       = var.project_name
  
  # ... other foundation inputs
}

# 2. Infrastructure
module "infrastructure" {
  source = "./modules/infrastructure"
  
  org_id            = module.foundation.org_id
  project_id        = module.foundation.project_id
  k8s_connector_id  = module.foundation.k8s_connector_id
  
  environment_identifier    = var.environment_identifier
  environment_name          = var.environment_name
  infrastructure_identifier = var.infrastructure_identifier
  infrastructure_name       = var.infrastructure_name
  
  # ... other infrastructure inputs
}

# 3. Chaos Infrastructure
module "chaos_infrastructure" {
  source = "./modules/chaos-infrastructure"
  
  org_id          = module.foundation.org_id
  project_id      = module.foundation.project_id
  environment_id  = module.infrastructure.environment_id
  infrastructure_id = module.infrastructure.infrastructure_id
  
  create_chaos_infrastructure = var.create_chaos_infrastructure
  setup_custom_registry       = var.setup_custom_registry
  
  # ... other chaos infra inputs
}

# 4. Service Discovery
module "service_discovery" {
  source = "./modules/service-discovery"
  
  count = var.create_sd_agent ? 1 : 0
  
  org_id                = module.foundation.org_id
  project_id            = module.foundation.project_id
  environment_id        = module.infrastructure.environment_id
  infrastructure_id     = module.infrastructure.infrastructure_id
  chaos_infrastructure_id = module.chaos_infrastructure.chaos_infrastructure_id
  
  # ... other SD inputs
}

# 5. Chaos Hubs
module "chaos_hubs" {
  source = "./modules/chaos-hubs"
  
  org_id          = module.foundation.org_id
  project_id      = module.foundation.project_id
  git_connector_id = module.foundation.git_connector_id
  
  create_chaos_hub                  = var.create_chaos_hub
  create_chaos_hub_v2_account_level = var.create_chaos_hub_v2_account_level
  create_chaos_hub_v2_org_level     = var.create_chaos_hub_v2_org_level
  create_chaos_hub_v2_project_level = var.create_chaos_hub_v2_project_level
  
  # ... other hub inputs
}

# 6. Security Governance
module "security_governance" {
  source = "./modules/security-governance"
  
  count = var.create_security_governance_condition || var.create_security_governance_rule ? 1 : 0
  
  org_id                  = module.foundation.org_id
  project_id              = module.foundation.project_id
  environment_id          = module.infrastructure.environment_id
  chaos_infrastructure_id = module.chaos_infrastructure.chaos_infrastructure_id
  
  create_condition = var.create_security_governance_condition
  create_rule      = var.create_security_governance_rule
  
  # ... other governance inputs
}
```

## Benefits of This Structure

### 1. Isolated Testing ✅

Each module can be tested independently:

```bash
# Test foundation only
cd tests/foundation
terraform init
terraform plan
terraform apply

# Test chaos infrastructure only
cd tests/chaos-infrastructure
terraform init
terraform plan
terraform apply
```

### 2. Clear Dependencies ✅

Module dependencies are explicit:

```
foundation
    ↓
infrastructure
    ↓
chaos-infrastructure
    ↓
service-discovery
    ↓
security-governance

chaos-hubs (parallel to infrastructure)
```

### 3. Reusability ✅

Modules can be used independently:

```hcl
# Use only chaos hubs module
module "chaos_hubs" {
  source = "git::https://github.com/org/chaos-terraform-module.git//modules/chaos-hubs"
  
  org_id     = "existing-org"
  project_id = "existing-project"
  
  create_chaos_hub_v2_project_level = true
}
```

### 4. Maintainability ✅

- Each module is self-contained (< 200 lines)
- Clear responsibility for each module
- Easy to update individual components
- Better code organization

### 5. Documentation ✅

Each module has its own README:
- Purpose and scope
- Input variables
- Output values
- Usage examples
- Testing instructions

## Migration Strategy

### Phase 1: Create Module Structure (Non-Breaking)

1. ✅ Create `modules/` directory
2. ✅ Extract resources into sub-modules
3. ✅ Keep root `main.tf` as orchestrator
4. ✅ Maintain backward compatibility

**Result**: Existing configurations work unchanged

### Phase 2: Add Tests

1. ✅ Create `tests/` directory
2. ✅ Add isolated tests for each module
3. ✅ Add integration tests

### Phase 3: Add Examples

1. ✅ Create `examples/` directory
2. ✅ Add minimal, complete, and existing-resources examples

### Phase 4: Documentation

1. ✅ Update root README
2. ✅ Add module READMEs
3. ✅ Add migration guide

## Testing Strategy

### Unit Tests (Isolated Modules)

```bash
# Test each module independently
cd tests/foundation
terraform init
terraform plan

cd tests/infrastructure
terraform init
terraform plan

cd tests/chaos-infrastructure
terraform init
terraform plan
```

### Integration Tests

```bash
# Test full module composition
cd tests/integration
terraform init
terraform plan
terraform apply
```

### E2E Tests

```bash
# Use existing e2e-test directory
cd e2e-test
terraform init
terraform plan
terraform apply
```

## Implementation Checklist

### Phase 1: Structure (Week 1)
- [ ] Create `modules/` directory structure
- [ ] Extract foundation module
- [ ] Extract infrastructure module
- [ ] Extract chaos-infrastructure module
- [ ] Extract service-discovery module
- [ ] Extract chaos-hubs module
- [ ] Extract security-governance module
- [ ] Update root `main.tf` to use modules
- [ ] Test backward compatibility

### Phase 2: Testing (Week 2)
- [ ] Create `tests/` directory
- [ ] Add unit tests for each module
- [ ] Add integration tests
- [ ] Verify all tests pass

### Phase 3: Examples (Week 2)
- [ ] Create `examples/` directory
- [ ] Add minimal example
- [ ] Add complete example
- [ ] Add existing-resources example
- [ ] Test all examples

### Phase 4: Documentation (Week 3)
- [ ] Update root README
- [ ] Add module READMEs
- [ ] Add migration guide
- [ ] Add testing guide
- [ ] Update CHANGELOG

## Backward Compatibility

**Critical**: All existing configurations must work unchanged

### How We Ensure This:

1. ✅ Root module maintains same interface
2. ✅ All variables stay in root `variables.tf`
3. ✅ All outputs stay in root `outputs.tf`
4. ✅ Module composition is internal detail
5. ✅ No breaking changes to API

### Example:

**Before** (single main.tf):
```hcl
module "chaos" {
  source = "git::https://github.com/org/chaos-terraform-module.git"
  
  org_identifier = "my-org"
  project_name   = "my-project"
  # ... other vars
}
```

**After** (modular structure):
```hcl
module "chaos" {
  source = "git::https://github.com/org/chaos-terraform-module.git"
  
  org_identifier = "my-org"
  project_name   = "my-project"
  # ... other vars (SAME AS BEFORE)
}
```

**Result**: ✅ No changes needed to existing code

## File Size Comparison

### Before:
```
main.tf: 535 lines
```

### After:
```
main.tf: ~100 lines (orchestration)
modules/foundation/main.tf: ~80 lines
modules/infrastructure/main.tf: ~60 lines
modules/chaos-infrastructure/main.tf: ~100 lines
modules/service-discovery/main.tf: ~40 lines
modules/chaos-hubs/main.tf: ~120 lines
modules/security-governance/main.tf: ~100 lines
```

**Benefits**:
- ✅ Each file < 150 lines
- ✅ Clear separation of concerns
- ✅ Easy to understand and maintain

## Next Steps

1. **Review and Approve**: Review this plan
2. **Phase 1 Implementation**: Create module structure
3. **Testing**: Verify backward compatibility
4. **Phase 2 Implementation**: Add tests
5. **Phase 3 Implementation**: Add examples
6. **Phase 4 Implementation**: Update documentation
7. **Release**: Tag new version

## Estimated Timeline

- **Phase 1** (Structure): 2-3 days
- **Phase 2** (Testing): 2-3 days
- **Phase 3** (Examples): 1-2 days
- **Phase 4** (Documentation): 1-2 days

**Total**: 1-2 weeks for complete restructuring

## Questions to Consider

1. Should we keep the current single-file structure as an option?
2. Should we version the modules separately?
3. Should we publish modules to Terraform Registry?
4. Should we add CI/CD for automated testing?

## Recommendation

✅ **Proceed with restructuring** using the modular approach

**Benefits**:
- Better maintainability
- Isolated testing
- Clear separation of concerns
- Backward compatible
- Production ready

Would you like me to start implementing Phase 1?
