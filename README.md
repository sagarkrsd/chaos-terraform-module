# Harness Chaos Engineering Terraform Demo

This Terraform configuration sets up a complete Harness Chaos Engineering environment, including organizations, projects, Kubernetes connectors, chaos infrastructure, and security governance rules. It's designed to help you quickly get started with Harness Chaos Engineering in your own environment.

## Features

- Creates a new organization and project (optional)
- Sets up a Kubernetes connector using an existing Harness Delegate
- Creates a new environment
- Creates a Kubernetes infrastructure definition
- Configures Chaos Image Registry at both organization and project levels
- Deploys a Chaos Infrastructure V2
- Sets up a Service Discovery Agent for automatic service discovery
- Configures a Chaos Hub with Chaos experiments
- Implements security governance to block destructive experiments

## Prerequisites

- Terraform 1.0.0 or later
- Harness Account with appropriate permissions
- Harness API key with appropriate permissions
- Harness Delegate installed on your Kubernetes cluster (default selector: `chaos-delegate`)
- Kubernetes cluster for deploying chaos infrastructure

## Getting Started

1. Clone this repository:
```bash
git clone https://github.com/sagarkrsd/chaos-terraform-demo.git
cd chaos-terraform-demo
```

2. Create a `terraform.tfvars` file with your configuration. Here's an example:

```hcl
# Organization and Project
org_name     = "chaos terraform demo"
project_name = "chaos terraform demo"

# Kubernetes Configuration
namespace          = "harness-chaos"
delegate_selectors = ["chaos-delegate"]

# Infrastructure
environment_identifier = "tf-demo-env"
infrastructure_name   = "chaos-demo-infra"

# Chaos Hub Configuration
create_chaos_hub = true
chaos_hub_name   = "litmus-chaos-hub"
chaos_hub_url    = "https://github.com/litmuschaos/chaos-hub.git"

# Security
security_governance_condition_faults = [
    {
      fault_type = "FAULT"
      name       = "pod-delete"
    },
    {
      fault_type = "FAULT"
      name       = "container-kill"
    }
  ]

# Tags
tags = {
  environment = "dev"
  team        = "sre"
  managed_by  = "terraform"
}
```

3. Initialize Terraform:
```bash
terraform init
```

4. Review the execution plan:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

## Configuration

### Required Variables
- `harness_platform_api_key`: Your Harness API key with appropriate permissions
- `harness_account_id`: Your Harness account ID

### Common Variables
- `org_name`: Name of the organization to create
- `project_name`: Name of the project to create
- `namespace`: Kubernetes namespace for chaos resources
- `delegate_selectors`: List of delegate selectors for the Kubernetes connector
- `hub_connector_id`: ID of the Git connector for the Chaos Hub
- `hub_connector_scope`: Scope of the Git connector for the Chaos Hub

### Optional Variables
- `create_chaos_hub`: Whether to create a chaos hub (default: true)
- `blocked_experiments`: List of experiment names to block (default: ["pod-delete", "pod-network-loss"])
- `tags`: Common tags for all resources

## Key Components

### 1. Organization and Project
- Creates a new Harness organization and project (optional)
- Configures project-level settings and metadata

### 2. Kubernetes Connector
- Sets up a Kubernetes connector using your existing Harness Delegate
- Configures the necessary permissions for chaos operations

### 3. Chaos Infrastructure
- Deploys a Chaos Infrastructure V2
- Configures the infrastructure with appropriate settings
- Sets up service discovery for automatic target discovery

### 4. Image Registry
- Configures container registry access for chaos components
- Supports multiple registry types (DockerHub, ECR, GCR, etc.)

### 5. Chaos Hub
- Sets up a Chaos Hub with pre-configured experiments
- Can be configured to use the public Litmus Chaos Hub or a private repository

### 6. Security Governance
- Implements security controls to prevent destructive operations
- Blocks specified experiments from being executed
- Configures RBAC and access controls

## Outputs

The following outputs are available:

- `organization_id`: The ID of the created organization
- `project_id`: The ID of the created project
- `environment_id`: The ID of the created environment
- `kubernetes_connector_id`: The ID of the Kubernetes connector
- `infrastructure_id`: The ID of the infrastructure definition
- `chaos_infrastructure_id`: The ID of the Chaos Infrastructure
- `chaos_hub_id`: The ID of the Chaos Hub (if created)
- `service_discovery_agent_id`: The ID of the Service Discovery Agent
- `security_governance_condition_id`: The ID of the Security Governance Condition
- `security_governance_rule_id`: The ID of the Security Governance Rule

## Cleaning Up

To destroy all created resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Delegate Connection Issues**
   - Ensure your delegate is running and healthy
   - Verify the delegate selectors match those in your configuration
   - Check delegate logs for connection issues

2. **Permissions Errors**
   - Verify your API key has the required permissions
   - Check that the delegate service account has the necessary Kubernetes permissions

3. **Chaos Hub Connection**
   - If using a private repository, ensure the credentials are correct
   - Verify network connectivity to the Git repository

## Security Considerations

- Always store sensitive values (API keys, passwords) in environment variables or a secure secret store
- Use the principle of least privilege when configuring permissions
- Regularly rotate API keys and credentials
- Review and customize the security governance rules to match your organization's policies
- Enable audit logging for all chaos operations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue in the GitHub repository.
