# ============================================================================
# Step 11: Negative Test Scenarios
# ============================================================================
# These tests verify proper error handling for invalid configurations
# Set var.run_negative_tests = true to enable these tests

# ----------------------------------------------------------------------------
# Test 1: Invalid Hub Reference
# ----------------------------------------------------------------------------
# This should fail with "hub not found" error
resource "harness_chaos_action_template" "invalid_hub" {
  count = var.run_negative_tests ? 1 : 0

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = "non-existent-hub-12345"

  identity            = "negative-test-invalid-hub"
  name                = "Negative Test - Invalid Hub"
  description         = "This should fail - hub does not exist"
  type                = "customScript"
  infrastructure_type = "KubernetesV2"

  custom_script_action {
    command = "bash"
    args    = ["-c", "echo 'This should not run'"]
  }

  lifecycle {
    # Expect this to fail
    ignore_changes = all
  }
}

# ----------------------------------------------------------------------------
# Test 2: Invalid Template Reference in Experiment
# ----------------------------------------------------------------------------
# This should fail with "template not found" error
resource "harness_chaos_experiment" "invalid_template" {
  count = var.run_negative_tests ? 1 : 0

  depends_on = [
    harness_chaos_infrastructure_v2.this
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = "non-existent-template-12345"
  hub_identity      = local.project_hub_identity
  hub_org_id        = harness_platform_organization.this.id
  hub_project_id    = harness_platform_project.this.id

  name      = "Negative Test - Invalid Template"
  infra_ref = local.infra_ref

  identity    = "negative-test-invalid-template"
  description = "This should fail - template does not exist"

  lifecycle {
    ignore_changes = all
  }
}

# ----------------------------------------------------------------------------
# Test 3: Invalid Infrastructure Reference
# ----------------------------------------------------------------------------
# This should fail with "infrastructure not found" error
resource "harness_chaos_experiment" "invalid_infra" {
  count = var.run_negative_tests ? 1 : 0

  depends_on = [
    harness_chaos_experiment_template.project_complex
  ]

  org_id            = harness_platform_organization.this.id
  project_id        = harness_platform_project.this.id
  template_identity = local.exp_template_project_complex_identity
  hub_identity      = local.project_hub_identity
  hub_org_id        = harness_platform_organization.this.id
  hub_project_id    = harness_platform_project.this.id

  name      = "Negative Test - Invalid Infra"
  infra_ref = "invalid-env/invalid-infra"

  identity    = "negative-test-invalid-infra"
  description = "This should fail - infrastructure does not exist"

  lifecycle {
    ignore_changes = all
  }
}

# ----------------------------------------------------------------------------
# Test 4: Cross-Scope Permission Violation
# ----------------------------------------------------------------------------
# This should fail if trying to use account hub from project without permission
# Note: This may succeed if account resources are accessible from project
resource "harness_chaos_action_template" "cross_scope_violation" {
  count = var.run_negative_tests && var.test_cross_scope_violations ? 1 : 0

  # Try to create in project using account hub (may or may not fail)
  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = "account.${local.account_hub_identity}"

  identity            = "negative-test-cross-scope"
  name                = "Negative Test - Cross Scope"
  description         = "Testing cross-scope access"
  type                = "customScript"
  infrastructure_type = "KubernetesV2"

  custom_script_action {
    command = "bash"
    args    = ["-c", "echo 'Testing cross-scope'"]
  }

  lifecycle {
    ignore_changes = all
  }
}

# ----------------------------------------------------------------------------
# Test 5: Missing Required Fields
# ----------------------------------------------------------------------------
# These tests are commented out as they would cause Terraform validation errors
# Uncomment to test Terraform's validation logic

# resource "harness_chaos_action_template" "missing_hub" {
#   count = var.run_negative_tests ? 1 : 0
#   
#   org_id     = harness_platform_organization.this.id
#   project_id = harness_platform_project.this.id
#   # hub_identity missing - should fail validation
#   
#   identity            = "negative-test-missing-hub"
#   name                = "Negative Test - Missing Hub"
#   type                = "customScript"
#   infrastructure_type = "KubernetesV2"
# }

# resource "harness_chaos_experiment" "missing_infra_ref" {
#   count = var.run_negative_tests ? 1 : 0
#   
#   org_id            = harness_platform_organization.this.id
#   project_id        = harness_platform_project.this.id
#   template_identity = local.exp_template_project_complex_identity
#   hub_identity      = local.project_hub_identity
#   
#   name = "Negative Test - Missing Infra Ref"
#   # infra_ref missing - should fail validation
# }

# ----------------------------------------------------------------------------
# Test 6: Invalid Infrastructure Type
# ----------------------------------------------------------------------------
# This should fail with validation error for unsupported infrastructure type
# Commented out as it causes Terraform validation error

# resource "harness_chaos_action_template" "invalid_infra_type" {
#   count = var.run_negative_tests ? 1 : 0
#   
#   org_id       = harness_platform_organization.this.id
#   project_id   = harness_platform_project.this.id
#   hub_identity = local.project_hub_identity
#   
#   identity            = "negative-test-invalid-type"
#   name                = "Negative Test - Invalid Infra Type"
#   type                = "customScript"
#   infrastructure_type = "InvalidType"  # Should fail
# }

# ----------------------------------------------------------------------------
# Test 7: Duplicate Identity
# ----------------------------------------------------------------------------
# This should fail with "resource already exists" error
resource "harness_chaos_action_template" "duplicate_identity" {
  count = var.run_negative_tests && var.test_duplicate_resources ? 1 : 0

  depends_on = [
    harness_chaos_action_template.project_level
  ]

  org_id       = harness_platform_organization.this.id
  project_id   = harness_platform_project.this.id
  hub_identity = local.project_hub_identity

  # Use same identity as existing template
  identity            = local.action_template_project_identity
  name                = "Negative Test - Duplicate Identity"
  description         = "This should fail - identity already exists"
  type                = "customScript"
  infrastructure_type = "KubernetesV2"

  custom_script_action {
    command = "bash"
    args    = ["-c", "echo 'This should not run'"]
  }

  lifecycle {
    ignore_changes = all
  }
}

# ----------------------------------------------------------------------------
# Outputs for Negative Tests
# ----------------------------------------------------------------------------
output "negative_tests_enabled" {
  description = "Whether negative tests are enabled"
  value       = var.run_negative_tests
}

output "negative_tests_summary" {
  description = "Summary of negative test configurations"
  value = var.run_negative_tests ? {
    invalid_hub_test              = length(harness_chaos_action_template.invalid_hub) > 0
    invalid_template_test         = length(harness_chaos_experiment.invalid_template) > 0
    invalid_infra_test            = length(harness_chaos_experiment.invalid_infra) > 0
    cross_scope_violation_test    = var.test_cross_scope_violations
    duplicate_identity_test       = var.test_duplicate_resources
    total_negative_tests_expected = 3 + (var.test_cross_scope_violations ? 1 : 0) + (var.test_duplicate_resources ? 1 : 0)
  } : null
}
