# End-to-End Chaos Engineering Terraform Module Test

This directory contains a comprehensive end-to-end test that demonstrates the complete chaos engineering workflow using Harness Terraform resources.

## Test Flow

This test creates resources in the following sequence:

### 1. Foundation (Steps 1-2)
- **Organization**: Creates a new organization for chaos engineering
- **Project**: Creates a new project within the organization

### 2. Chaos Hubs (Step 3)
Creates chaos hubs at all three scopes:
- **Account Level Hub**: For account-wide templates
- **Org Level Hub**: For organization-wide templates  
- **Project Level Hub**: For project-specific templates

### 3. Templates at All Scopes (Step 4)
Creates the following templates at **each scope** (account, org, project):

#### Custom Templates (Using Custom Hub)
- **1 Action Template**: Custom script/delay/container action
- **1 Probe Template**: Custom HTTP/CMD/K8s probe
- **1 Fault Template**: Custom BYOC fault
- **1 Experiment Template (Custom)**: Uses all custom templates above

#### Enterprise Templates (Using Enterprise Hub)
- **1 Experiment Template (Enterprise)**: Uses enterprise fault/probe/action templates

### 4. Infrastructure Setup (Steps 5-10)
- **Environment**: PreProduction environment
- **Platform Infrastructure**: Kubernetes infrastructure definition
- **Chaos Infrastructure V2**: Chaos-specific infrastructure
- **Service Discovery Agent**: For application discovery
- **Chaos Image Registry**: Custom registry configuration (optional)
- **Security Governance**: Rules and conditions for chaos experiments

### 5. Experiments (Steps 11-14)
Creates experiments from templates at all levels:
- **From Project Templates**: Both custom and enterprise
- **From Org Templates**: Both custom and enterprise
- **From Account Templates**: Both custom and enterprise

## File Structure

```
e2e-test/
├── README.md                           # This file
├── 01-foundation.tf                    # Org and Project
├── 02-chaos-hubs.tf                    # Hubs at all scopes
├── 03-templates-account.tf             # Account-level templates
├── 04-templates-org.tf                 # Org-level templates
├── 05-templates-project.tf             # Project-level templates
├── 06-infrastructure.tf                # Environment, infra, chaos infra
├── 07-security-governance.tf           # Security rules and conditions
├── 08-experiments-project.tf           # Experiments from project templates
├── 09-experiments-org.tf               # Experiments from org templates
├── 10-experiments-account.tf           # Experiments from account templates
├── variables.tf                        # Input variables
├── outputs.tf                          # Output values
├── providers.tf                        # Provider configuration
├── terraform.tfvars.example            # Example variable values
└── version.tf                          # Terraform version constraints
```

## Prerequisites

1. **Harness Account**: Active Harness account with Chaos Engineering enabled
2. **API Key**: Harness API key with appropriate permissions
3. **Kubernetes Cluster**: A running Kubernetes cluster with delegate installed
4. **Git Repository**: (Optional) For custom chaos hub

## Usage

### Step 1: Configure Variables

Copy the example tfvars file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values.

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Plan the Deployment

```bash
terraform plan -out=tfplan
```

### Step 4: Apply the Configuration

```bash
terraform apply tfplan
```

### Step 5: Verify the Deployment

```bash
terraform output
```

### Step 6: Cleanup

```bash
terraform destroy
```

## Expected Outcomes

After successful deployment:
- **3 Chaos Hubs**: Account, Org, Project levels
- **15 Templates**: 5 at each scope (action, probe, fault, 2 experiment templates)
- **1 Infrastructure Stack**: Environment, platform infra, chaos infra
- **1 Service Discovery Agent**: For application discovery
- **2 Security Governance Resources**: Condition and rule
- **6 Experiments**: 2 from each scope (custom + enterprise)

Total: **28 Chaos Engineering Resources** + Foundation (org, project, connectors)
