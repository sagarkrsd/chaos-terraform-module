# ============================================================================
# Step 4c: Project-Level Templates
# ============================================================================

# ----------------------------------------------------------------------------
# 1. Action Template - Project Level
# ----------------------------------------------------------------------------
resource "harness_chaos_action_template" "project_level" {
  count = local.create_action_templates && var.enable_project_scope_resources ? 1 : 0

  depends_on = [harness_chaos_hub_v2.project_level]

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity

  identity            = "e2e-action-project"
  name                = "E2E Action Template Project"
  description         = "Project-level action template for E2E test"
  type                = "container"
  infrastructure_type = "<+input>.default('Kubernetes')"
  tags                = ["e2e", "project", "action"]

  # Container action
  container_action {
    image     = "<+input>.default('busybox:latest')"
    command   = ["<+input>.default('sh')"]
    args      = "echo 'Project-level container action'; sleep 15"
    namespace = "<+input>.default('default')"

    node_selector = {
      disktype = "ssd"
      zone     = "us-west-1a"
    }

    labels = {
      app         = "e2e-action-project"
      environment = "e2e"
      managed-by  = "terraform"
    }

    annotations = {
      description = "Project-level container action"
      owner       = "e2e"
    }

    env {
      name  = "TEST_VAR"
      value = "<+input>.default('test_value')"
    }

    env {
      name  = "ANOTHER_VAR"
      value = "<+input>.default('another_value')"
    }

    resources {
      limits = {
        cpu    = "500m"
        memory = "512Mi"
      }

      requests = {
        cpu    = "250m"
        memory = "256Mi"
      }
    }
  }

  # Run properties
  run_properties {
    timeout  = "<+input>.default('60s')"
    interval = "<+input>.default('15s')"
  }

  variables {
    name        = "container_image"
    value       = "<+input>"
    type        = "string"
    required    = true
    description = "Container image to use (runtime input)"
  }

  variables {
    name        = "namespace"
    value       = "<+input>"
    type        = "string"
    required    = false
    description = "Kubernetes namespace (runtime input)"
  }

}

# ----------------------------------------------------------------------------
# 2. Probe Template - Project Level
# ----------------------------------------------------------------------------
resource "harness_chaos_probe_template" "project_level" {
  count = local.create_probe_templates && var.enable_project_scope_resources ? 1 : 0

  depends_on = [harness_chaos_hub_v2.project_level]

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity

  identity            = "e2e-probe-project"
  name                = "E2E Probe Template Project"
  description         = "Project-level probe template for E2E test"
  type                = "k8sProbe"
  infrastructure_type = "KubernetesV2"
  tags                = ["e2e", "project", "probe"]

  # K8s probe
  k8s_probe {
    resource  = "deployments"
    namespace = var.namespace
    operation = "present"
    version   = "v1"
  }

  # Run properties
  run_properties {
    timeout         = "15s"
    interval        = "5s"
    stop_on_failure = false
  }
}

# ----------------------------------------------------------------------------
# 3. Fault Template - Project Level
# ----------------------------------------------------------------------------
resource "harness_chaos_fault_template" "project_level" {
  count = local.create_fault_templates && var.enable_project_scope_resources ? 1 : 0

  depends_on = [harness_chaos_hub_v2.project_level]

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity

  identity             = "e2e-fault-project"
  name                 = "E2E Fault Template Project"
  description          = "Project-level fault template for E2E test"
  category             = ["Kubernetes"]
  infrastructures      = ["KubernetesV2"]
  type                 = "Custom"
  permissions_required = "Basic"
  tags                 = ["e2e", "project", "fault"]

  # ---------------------------------------------------------------------------
  # Variables block - exercises the fault_template variables import/read fix.
  # Variables are parsed back from the stored template YAML on Read, so they
  # must round-trip without drift (and survive `terraform import`).
  #
  # To validate the UPDATE-via-PUT 500 fix: after the first apply, change a
  # value below (e.g. the CHAOS_DURATION default) or the description, then
  # re-apply. The update must succeed (no 500) and the subsequent plan must be
  # empty.
  # ---------------------------------------------------------------------------
  variables {
    name        = "TARGET_NAMESPACE"
    description = "Namespace to target"
    type        = "string"
    value       = "<+input>"
  }

  variables {
    name        = "CHAOS_DURATION"
    description = "Duration of chaos in seconds"
    type        = "string"
    value       = "<+input>.default('60')"
  }

  links {
    name = "Documentation"
    url  = "https://docs.harness.io"
  }

  spec {
    chaos {
      fault_name = "byoc-injector"

      params {
        name  = "CHAOS_DURATION"
        value = "15s"
      }
      params {
        name  = "CHAOS_INTERVAL"
        value = "3s"
      }

      kubernetes {
        image             = "chaosnative/go-runner:ci"
        command           = ["/bin/bash", "-c"]
        args              = ["echo 'Project-level fault running'; sleep 15"]
        image_pull_policy = "IfNotPresent"

        resources {
          limits = {
            cpu    = "150m"
            memory = "150Mi"
          }
        }
      }
    }
  }
}

# ----------------------------------------------------------------------------
# 4. Experiment Template (Custom) - Project Level
# Uses custom action, probe, and fault templates from project hub
# ----------------------------------------------------------------------------
resource "harness_chaos_experiment_template" "project_custom" {
  count = local.create_experiment_templates && var.enable_project_scope_resources ? 1 : 0

  depends_on = [
    harness_chaos_action_template.project_level,
    harness_chaos_probe_template.project_level,
    harness_chaos_fault_template.project_level
  ]

  # Project level - org_id and project_id
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity

  identity    = "e2e-exp-project-custom"
  name        = "E2E Experiment Template Project Custom"
  description = "Project-level experiment template using custom templates"
  tags        = ["e2e", "project", "custom"]

  spec {
    infra_type = "KubernetesV2"

    # Action from project hub
    actions {
      identity               = local.action_template_project_identity
      name                   = "project-action"
      is_enterprise          = false
      continue_on_completion = false
    }

    # Fault from project hub
    faults {
      identity      = local.fault_template_project_identity
      name          = "project-fault"
      revision      = "v1"
      is_enterprise = false
      auth_enabled  = false
    }

    # Probe from project hub
    probes {
      identity      = local.probe_template_project_identity
      name          = "project-probe"
      is_enterprise = false
      weightage     = 10
      duration      = "15s"
    }

    # Workflow vertices
    vertices {
      name = "v-start"
      start {
        actions {
          name = "project-action"
        }
      }
    }

    vertices {
      name = "v-fault"
      start {
        faults {
          name = "project-fault"
        }
        probes {
          name = "project-probe"
        }
      }
    }

    vertices {
      name = "v-end"
      end {
        faults {
          name = "project-fault"
        }
      }
    }

    cleanup_policy = "delete"
  }
}

# Enterprise experiment template removed - using complex template instead
# See: 06-experiment-template-complex.tf
