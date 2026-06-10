# Harness Chaos Engineering — Terraform Example

An end-to-end, reference Terraform configuration that provisions a complete
**Harness Chaos Engineering** setup — from foundational org/project resources,
through Kubernetes infrastructure and Chaos Infrastructure V2, all the way to
ChaosGuard (Security Governance) rules, reusable templates, and runnable chaos
experiments.

It is designed to be **copied and adapted** for your own environment. Every
resource is wired with explicit dependencies so that `terraform apply` creates
them in the correct, real-world order.

---

## Dependency Flow

Resources are linked (via `depends_on` and attribute references) to follow the
sequence a real user would perform:

```
 1. Delegate selectors (input)        ── you provide an already-installed delegate
 2. Organization                      ── harness_platform_organization.this
 3. Project                           ── harness_platform_project.this
 4. Kubernetes Connector              ── harness_platform_connector_kubernetes.this  (inherits from delegate)
 5. Environment                       ── harness_platform_environment.this
 6. Infrastructure Definition         ── harness_platform_infrastructure.this        (uses the K8s connector)
 7. Chaos Infrastructure V2           ── harness_chaos_infrastructure_v2.this         (on the infra above)
 8. Service Discovery Agent           ── harness_service_discovery_agent.this
 9. Chaos Image Registry              ── harness_chaos_image_registry.*               (org / project scope)
10. Security Governance (ChaosGuard)  ── harness_chaos_security_governance_{condition,rule}*  (target the infra)
11. Probe Templates                   ── harness_chaos_probe_template.*
12. Action Templates                  ── harness_chaos_action_template.*
13. Fault Templates                   ── harness_chaos_fault_template.*
14. Experiment Templates              ── harness_chaos_experiment_template.*          (compose probes/actions/faults)
15. Experiments                       ── harness_chaos_experiment.*                   (run on the infra, wait on SD + registry)
```

Steps 2–8 form a strict chain. Templates (11–14) hang off the Chaos Hubs.
Experiments (15) only run after the infrastructure is fully ready
(service discovery running + image registry configured).

---

## Repository Layout

The configuration is split into numbered files that mirror the flow above:

| File | Purpose |
|------|---------|
| `00-feature-flags.tf` | Feature flags + computed locals + status output |
| `01-foundation.tf` | Org, project, Kubernetes connector |
| `02-chaos-hubs.tf` | Chaos Hub V2 (account / org / project) |
| `06-infrastructure.tf` | Environment, infra definition, Chaos Infra V2, service discovery |
| `test-image-registry.tf` | Chaos image registry (org / project scope) |
| `03-templates-account.tf`, `04-templates-org.tf`, `05-templates-project.tf` | Action / probe / fault / experiment templates per scope |
| `02-experiment-template-account.tf`, `03-experiment-template-org.tf`, `06-experiment-template-project.tf` | Complex experiment templates per scope |
| `07-security-governance.tf` | Security Governance V1 (GraphQL) condition + rule |
| `16-security-governance-v3.tf` | Security Governance V3 (REST) conditions/rule + namespace-label scenarios |
| `08-experiments-project.tf`, `09-experiments-org.tf`, `10-experiments-account.tf` | Chaos experiments (REFERENCE + LOCAL import) |
| `variables.tf`, `variables-validation.tf` | Input variables + validation |
| `outputs.tf` | Outputs (IDs, identities, summaries) |
| `providers.tf`, `version.tf` | Provider + version constraints |

### Optional integration tests

These files exercise edge cases and are **gated by feature flags** (off or
isolated by default). They reference resources from the example above, so they
live in the same module rather than a separate directory:

| File | Flag | Default |
|------|------|---------|
| `11-negative-tests.tf` | `enable_negative_tests` | `false` |
| `12-validation-tests.tf` | `enable_validation_tests` | `true` |
| `13-preconditions.tf` | (always-on input assertions) | — |
| `14-update-tests.tf` | `enable_update_tests` | `true` |

To run **only the example flow** (no test scaffolding), set:

```hcl
enable_negative_tests   = false
enable_validation_tests = false
enable_update_tests     = false
```

---

## Prerequisites

- **Terraform** >= 1.0.0
- **Harness account** with permissions to manage orgs, projects, connectors,
  environments, and chaos resources
- **Harness platform API key** (`x-api-key`)
- A **Harness Delegate** already installed in your Kubernetes cluster — you pass
  its selector(s) via `delegate_selectors`
- A reachable **Kubernetes cluster** for the chaos infrastructure
- The **latest Harness Terraform provider** — Chaos Infrastructure V2, Service
  Discovery, Image Registry, Chaos Hub V2, the template resources, and Security
  Governance V3 require a recent provider release (see `version.tf`)

---

## Quick Start

1. Copy the example variables and edit them:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # edit terraform.tfvars: set delegate_selectors, namespace, identifiers, etc.
   ```

2. Provide credentials (recommended via environment variables):

   ```bash
   export TF_VAR_harness_account_id="<your_account_id>"
   export TF_VAR_harness_platform_api_key="<your_api_key>"
   ```

3. Initialize, review, and apply:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

---

## Configuration

### Credentials (required)

| Variable | Description |
|----------|-------------|
| `harness_account_id` | Your Harness account ID |
| `harness_platform_api_key` | Harness platform API key (sensitive) |
| `harness_endpoint` | API endpoint (default `https://app.harness.io/gateway`) |

### Key inputs

| Variable | Description |
|----------|-------------|
| `delegate_selectors` | Selectors of your pre-installed delegate (the K8s connector inherits from it) |
| `org_identifier` / `org_name` | Organization to create |
| `project_identifier` / `project_name` | Project to create |
| `namespace` | Kubernetes namespace for chaos resources |
| `environment_identifier` / `infrastructure_identifier` | Environment + infra definition |
| `setup_custom_registry` | Set `true` to configure a private image registry |

See `terraform.tfvars.example` for the full set, plus ready-made **presets**
(minimal, templates-only, single-scope).

### Feature flags

Every stage can be toggled independently (defaults shown). Base resources
(org, project, connectors) are **always** created.

| Flag | Default | Controls |
|------|---------|----------|
| `enable_chaos_hubs` | `true` | Chaos Hub V2 at all scopes |
| `enable_templates` | `true` | Action / probe / fault / experiment templates |
| `enable_experiment_templates` | `true` | Experiment templates |
| `enable_experiments` | `true` | Runnable chaos experiments |
| `enable_infrastructure` | `true` | Chaos Infrastructure V2 |
| `enable_service_discovery` | `true` | Service Discovery agent |
| `enable_image_registry` | `true` | Image registry config |
| `enable_security_governance` | `true` | ChaosGuard V1 (GraphQL) |
| `enable_security_governance_v3` | `true` | ChaosGuard V3 (REST) |
| `enable_account_scope_resources` | `true` | Account-level hubs/templates |
| `enable_org_scope_resources` | `true` | Org-level hubs/templates |
| `enable_project_scope_resources` | `true` | Project-level hubs/templates |

Run `terraform output feature_flags_status` after an apply to see exactly what
was created.

---

## Outputs

Key outputs include the organization/project/environment/infrastructure IDs,
the Chaos Infrastructure V2 ID, service discovery agent ID, security governance
condition/rule IDs, and the identities of all created templates and experiments.
See `outputs.tf`.

---

## Helper Scripts

The `scripts/` directory contains optional utilities:

| Script | Purpose |
|--------|---------|
| `pre-flight-check.sh` | Validate prerequisites before applying |
| `validate-deployment.sh` | Verify resources after apply |
| `drift-test.sh` | Check for configuration drift |
| `cleanup.sh` | Assisted teardown |

---

## Cleanup

```bash
terraform destroy
```

Chaos Hubs have a teardown constraint: at least one hub must exist in a project
until project-level resources are removed. The configuration already orders hub
deletion (account/org hubs depend on the project hub) so `terraform destroy`
handles this automatically.

---

## Notes & Troubleshooting

- **Delegate connectivity** — ensure the delegate is healthy and its selector
  matches `delegate_selectors`.
- **Provider version** — if `terraform init` selects an older provider that
  lacks the chaos resources, upgrade with `terraform init -upgrade`.
- **Secrets** — never commit `terraform.tfvars` or state. The `.gitignore`
  already excludes `*.tfvars` (except `terraform.tfvars.example`), `*.tfstate*`,
  and `.terraform/`.

---

## License

MIT — see `LICENSE`.
