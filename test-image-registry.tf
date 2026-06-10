# Image Registry E2E Tests - Hierarchical Inheritance
# 
# IMPORTANT: Image registry uses hierarchical inheritance:
# - Account-level settings are inherited by org and project
# - Lower scopes can override ONLY if parent allows (is_override_allowed = true)
# - Resources must be created SEQUENTIALLY to avoid cascade conflicts
#
# Test Strategy:
# 1. Create account-level first (allows overrides)
# 2. Create org-level second (overrides account, allows project overrides)
# 3. Create project-level third (overrides org)


# =============================================================================
# Phase 1: Account-Level Registry (Top of Hierarchy)
# =============================================================================
# DISABLED for e2e: the account-level image registry is a shared, account-wide
# singleton (keyed by scope). Creating/updating it mutates settings that affect
# the whole account, so we intentionally do not manage it here.
# resource "harness_chaos_image_registry" "test_account_level" {
#   # No org_id = account-level registry (highest scope)
#
#   registry_server  = "docker.io"
#   registry_account = "harness"
#
#   is_default          = false
#   is_override_allowed = true  # ← CRITICAL: Allows org and project to override
#   is_private          = false
#   use_custom_images   = false
#
#   # No custom_images block - tests nil handling
# }

# =============================================================================
# Phase 2: Org-Level Registry (Middle of Hierarchy)
# =============================================================================
resource "harness_chaos_image_registry" "test_org_level" {
  # Account-level registry is intentionally not managed in e2e (see above),
  # so the org-level registry no longer depends on it.

  org_id = harness_platform_organization.this.id
  # No project_id = org-level registry

  registry_server  = "docker.io"
  registry_account = "harness" # ← Overrides account value

  is_default          = false
  is_override_allowed = true # ← CRITICAL: Allows project to override
  is_private          = false
  use_custom_images   = false

  // custom_images {
  //   log_watcher = "docker.io/harness/log-watcher:v2.0.0"
  //   ddcr        = "docker.io/harness/ddcr:v2.0.0"
  //   ddcr_lib    = "docker.io/harness/ddcr-lib:v2.0.0"
  //   ddcr_fault  = "docker.io/harness/ddcr-fault:v2.0.0"
  // }
}

# =============================================================================
# Phase 3: Project-Level Registry (Bottom of Hierarchy)
# =============================================================================
resource "harness_chaos_image_registry" "test_project_level" {
  # Explicit dependency: Create AFTER org-level
  depends_on = [harness_chaos_image_registry.test_org_level]

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  # No infra_id = project-level registry

  registry_server  = "docker.io"
  registry_account = "harness" # ← Overrides org value

  is_default          = false
  is_override_allowed = true
  is_private          = false
  use_custom_images   = true # ← Different from parent scopes

  # Test custom images with all fields populated
  custom_images {
    log_watcher = "docker.io/harness/chaos-log-watcher:1.88.0"
    ddcr        = "docker.io/harness/chaos-ddcr:1.88.0"
    ddcr_lib    = "docker.io/harness/chaos-ddcr-faults:1.88.0"
    ddcr_fault  = "docker.io/harness/chaos-ddcr-faults:1.88.0"
  }
}

# =============================================================================
# Phase 4: Infra-Level Registry (Bottom of Hierarchy, requires chaos infra)
# =============================================================================
# Only created when chaos infrastructure exists (enable_infrastructure = true).
# infra_id is the chaos infrastructure identifier. is_private is kept false so
# no real pull secret is required for the e2e run; set is_private = true and
# secret_name to an existing secret to mirror a private-registry setup.
resource "harness_chaos_image_registry" "test_infra_level" {
  count = local.create_infrastructure ? 1 : 0

  # Explicit dependency: create AFTER project-level and the chaos infra
  depends_on = [
    harness_chaos_image_registry.test_project_level,
    harness_chaos_infrastructure_v2.this,
  ]

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  infra_id   = harness_chaos_infrastructure_v2.this[0].infra_id

  registry_server  = "docker.io"
  registry_account = "harness" # ← Overrides project value

  is_default          = false
  is_override_allowed = false
  is_private          = false
  use_custom_images   = true

  custom_images {
    log_watcher = "docker.io/harness/chaos-log-watcher:1.88.0"
    ddcr        = "docker.io/harness/chaos-ddcr:1.88.0"
    ddcr_lib    = "docker.io/harness/chaos-ddcr-faults:1.88.0"
    ddcr_fault  = "docker.io/harness/chaos-ddcr-faults:1.88.0"
  }
}

# =============================================================================
# Test 4: Update Test - Change registry_account
# =============================================================================
# This tests that changing registry_account works without drift
# Just modify the registry_account value and apply again

# =============================================================================
# Test 5: Update Test - Add custom images
# =============================================================================
# Modify test_project_level to add custom_images block and apply

# =============================================================================
# Outputs
# =============================================================================
# output "account_registry_id" {
#   value = harness_chaos_image_registry.test_account_level.id
# }

output "org_registry_id" {
  value = harness_chaos_image_registry.test_org_level.id
}

output "project_registry_id" {
  value = harness_chaos_image_registry.test_project_level.id
}

output "infra_registry_id" {
  value = try(harness_chaos_image_registry.test_infra_level[0].id, "")
}

# =============================================================================
# Data Source Verification
# =============================================================================
# data "harness_chaos_image_registry" "verify_account" {
#   # No org_id = account-level lookup
#
#   depends_on = [harness_chaos_image_registry.test_account_level]
# }

data "harness_chaos_image_registry" "verify_org" {
  org_id = harness_platform_organization.this.id

  depends_on = [harness_chaos_image_registry.test_org_level]
}

data "harness_chaos_image_registry" "verify_project" {
  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id

  depends_on = [harness_chaos_image_registry.test_project_level]
}

data "harness_chaos_image_registry" "verify_infra" {
  count = local.create_infrastructure ? 1 : 0

  org_id     = harness_platform_organization.this.id
  project_id = harness_platform_project.this.id
  infra_id   = harness_chaos_infrastructure_v2.this[0].infra_id

  depends_on = [harness_chaos_image_registry.test_infra_level]
}

# output "verify_account_registry_account" {
#   value = data.harness_chaos_image_registry.verify_account.registry_account
# }

output "verify_org_registry_account" {
  value = data.harness_chaos_image_registry.verify_org.registry_account
}

output "verify_project_registry_account" {
  value = data.harness_chaos_image_registry.verify_project.registry_account
}
