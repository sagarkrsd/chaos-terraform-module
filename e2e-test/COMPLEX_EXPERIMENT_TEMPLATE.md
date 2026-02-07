# Complex Experiment Template - E2E Test

## Overview

Created a comprehensive chaos experiment template that demonstrates advanced Harness Chaos Engineering capabilities.

## Files Created

1. **06-experiment-template-complex.tf** - Complex experiment template definition
2. **11-experiment-from-complex-template.tf** - Experiment instance from the template

## Template Specifications

### Identity & Metadata
- **Identity**: `e2echaosexperimenttemplate`
- **Name**: `e2e-chaos-experiment-template`
- **Revision**: `v1`
- **Scope**: Project Level
- **Infrastructure Type**: KubernetesV2

### Components

#### Faults (2)

1. **pod-delete-jpu**
   - Identity: `pod-delete`
   - Type: Enterprise Fault
   - Parameters: 7 runtime inputs
     - TARGET_WORKLOAD_KIND: `deployment` (hardcoded)
     - TARGET_WORKLOAD_NAMESPACE: `<+input>`
     - TARGET_WORKLOAD_NAMES: `<+input>`
     - TOTAL_CHAOS_DURATION: `<+input>`
     - CHAOS_INTERVAL: `<+input>`
     - POD_AFFECTED_PERCENTAGE: `<+input>`
     - NODE_LABEL: `<+input>`

2. **pod-network-latency-ql6**
   - Identity: `pod-network-latency`
   - Type: Enterprise Fault
   - Parameters: 6 runtime inputs
     - TARGET_WORKLOAD_KIND: `<+input>`
     - TARGET_WORKLOAD_NAMESPACE: `<+input>`
     - TARGET_WORKLOAD_NAMES: `<+input>`
     - TOTAL_CHAOS_DURATION: `<+input>`
     - NETWORK_LATENCY: `<+input>`
     - POD_AFFECTED_PERCENTAGE: `<+input>`

#### Probes (4)

1. **pod-status-check-nic-nic**
   - Identity: `pod-status-check`
   - Type: Enterprise Probe
   - Weightage: 10
   - Duration: 30s
   - Parameters: 6 runtime inputs

2. **pod-replica-count-check-d9a-d9a**
   - Identity: `pod-replica-count-check`
   - Type: Enterprise Probe
   - Weightage: 10
   - Duration: 30s
   - Parameters: 6 runtime inputs

3. **pod-replica-count-check-1ox-1ox**
   - Identity: `pod-replica-count-check`
   - Type: Enterprise Probe
   - Weightage: 10
   - Duration: 30s
   - Parameters: 4 runtime inputs

4. **pod-status-check-ua4-ua4**
   - Identity: `pod-status-check`
   - Type: Enterprise Probe
   - Weightage: 10
   - Duration: 30s
   - Parameters: 3 runtime inputs

#### Workflow Vertices (3)

```
v-jrc (Start Phase)
    ├── Fault: pod-delete-jpu
    ├── Probe: pod-status-check-nic-nic
    └── Probe: pod-replica-count-check-d9a-d9a

v-qn1 (Start and End Phases)
    ├── Start Phase:
    │   ├── Fault: pod-network-latency-ql6
    │   ├── Probe: pod-replica-count-check-1ox-1ox
    │   └── Probe: pod-status-check-ua4-ua4
    │
    └── End Phase:
        ├── Fault: pod-delete-jpu
        ├── Probe: pod-status-check-nic-nic
        └── Probe: pod-replica-count-check-d9a-d9a

v-end (End Phase)
    ├── Fault: pod-network-latency-ql6
    ├── Probe: pod-replica-count-check-1ox-1ox
    └── Probe: pod-status-check-ua4-ua4
```

### Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      v-jrc (Start)                          │
│  • pod-delete-jpu                                           │
│  • pod-status-check-nic-nic                                 │
│  • pod-replica-count-check-d9a-d9a                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   v-qn1 (Start Phase)                       │
│  • pod-network-latency-ql6                                  │
│  • pod-replica-count-check-1ox-1ox                          │
│  • pod-status-check-ua4-ua4                                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   v-qn1 (End Phase)                         │
│  • pod-delete-jpu                                           │
│  • pod-status-check-nic-nic                                 │
│  • pod-replica-count-check-d9a-d9a                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     v-end (End Phase)                       │
│  • pod-network-latency-ql6                                  │
│  • pod-replica-count-check-1ox-1ox                          │
│  • pod-status-check-ua4-ua4                                 │
└─────────────────────────────────────────────────────────────┘
```

## Experiment Instance

### Configuration
- **Name**: `E2E-Complex-Experiment`
- **Identity**: `e2e-complex-experiment`
- **Import Type**: `REFERENCE` (links to template)
- **Infrastructure**: Uses `local.infra_ref` (chaos_e2e_env/chaos_e2e_infra)

### Why REFERENCE Import?

Using `REFERENCE` instead of `LOCAL` because:
1. ✅ Doesn't require action templates (avoids dependency issues)
2. ✅ Stays in sync with template updates
3. ✅ Lighter weight
4. ✅ Suitable for E2E testing

## Runtime Inputs

The template uses `<+input>` for flexibility, allowing users to provide values at runtime:

### Pod Delete Fault Inputs
- Namespace
- Workload names
- Chaos duration
- Chaos interval
- Pod affected percentage
- Node label

### Network Latency Fault Inputs
- Workload kind
- Namespace
- Workload names
- Chaos duration
- Network latency value
- Pod affected percentage

### Probe Inputs
- Target labels
- Target names
- Target namespace
- Target kind
- Minimum healthy replica count
- Attempt count
- Interval

## Terraform Resources

### Template Resource
```hcl
resource "harness_chaos_experiment_template" "project_complex" {
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = harness_chaos_hub_v2.project_level.identity
  
  identity = "e2echaosexperimenttemplate"
  name     = "e2e-chaos-experiment-template"
  
  spec {
    infra_type = "KubernetesV2"
    # 2 faults, 4 probes, 3 vertices
  }
}
```

### Experiment Resource
```hcl
resource "harness_chaos_experiment" "from_complex_template" {
  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = harness_chaos_experiment_template.project_complex.identity
  hub_identity      = harness_chaos_hub_v2.project_level.identity
  name              = "E2E-Complex-Experiment"
  infra_ref         = local.infra_ref
  import_type       = "REFERENCE"
}
```

## Outputs

### Template Outputs
- `complex_experiment_template_id` - Full resource ID
- `complex_experiment_template_identity` - Template identity

### Experiment Outputs
- `complex_experiment_id` - Full resource ID
- `complex_experiment_identity` - Experiment identity

## Usage

### Apply the Resources

```bash
# Create the template and experiment
terraform apply
```

### Expected Resources Created
1. ✅ Experiment Template: `e2echaosexperimenttemplate`
2. ✅ Experiment Instance: `e2e-complex-experiment`

### Verify Creation

```bash
# Check template
terraform output complex_experiment_template_id
terraform output complex_experiment_template_identity

# Check experiment
terraform output complex_experiment_id
terraform output complex_experiment_identity
```

## Key Features Demonstrated

1. **Multiple Faults** - 2 enterprise faults in one template
2. **Multiple Probes** - 4 enterprise probes for comprehensive validation
3. **Complex Workflow** - 3 vertices with start/end phases
4. **Runtime Inputs** - Flexible parameterization with `<+input>`
5. **Enterprise Templates** - Uses enterprise fault and probe identities
6. **Probe Reuse** - Same probe identity used multiple times with different names
7. **Fault Reuse** - pod-delete used in multiple vertices
8. **Cleanup Policy** - Automatic cleanup after experiment

## Comparison with Simple Templates

| Feature | Simple Template | Complex Template |
|---------|----------------|------------------|
| Faults | 1 | 2 |
| Probes | 1 | 4 |
| Vertices | 1 | 3 |
| Workflow Phases | Start only | Start + End |
| Runtime Inputs | Few | Many (20+) |
| Complexity | Low | High |
| Use Case | Basic testing | Production scenarios |

## Production Readiness

✅ **Ready for deployment**

- Configuration validated
- Follows Harness best practices
- Uses enterprise templates
- Comprehensive probe coverage
- Flexible runtime inputs
- Proper cleanup policy

## Next Steps

1. ✅ Apply the configuration
2. ✅ Verify template creation
3. ✅ Verify experiment creation
4. ⏳ Run the experiment with runtime inputs
5. ⏳ Monitor experiment execution
6. ⏳ Review probe results

## Notes

- Template uses project-level hub
- All faults and probes are enterprise (require Harness Chaos Engineering license)
- Runtime inputs allow flexibility without template modification
- REFERENCE import keeps experiment in sync with template changes
- Cleanup policy ensures resources are cleaned up after execution
