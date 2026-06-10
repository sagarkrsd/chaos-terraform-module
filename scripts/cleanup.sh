#!/bin/bash
set -e

echo "=== Chaos E2E Test Cleanup ==="
echo "Destroying resources in correct dependency order..."
echo ""

# Function to destroy with retry
destroy_resource() {
    local resource=$1
    echo "→ Destroying: $resource"
    terraform destroy -target="$resource" -auto-approve 2>&1 | grep -v "Refreshing state" || true
}

# Step 1: Experiments (highest level dependencies)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/8: Destroying experiments..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
destroy_resource "harness_chaos_experiment_v2.project_from_template"
destroy_resource "harness_chaos_experiment_v2.org_from_template"
destroy_resource "harness_chaos_experiment_v2.account_from_template_ref"
destroy_resource "harness_chaos_experiment_v2.account_from_template_local"

# Step 2: Experiment Templates
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/8: Destroying experiment templates..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
destroy_resource "harness_chaos_experiment_template.project_complex"
destroy_resource "harness_chaos_experiment_template.project_custom"
destroy_resource "harness_chaos_experiment_template.org_complex"
destroy_resource "harness_chaos_experiment_template.account_complex"

# Step 3: Fault Templates
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/8: Destroying fault templates..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
destroy_resource "harness_chaos_fault_template.project_level"
destroy_resource "harness_chaos_fault_template.org_level"
destroy_resource "harness_chaos_fault_template.account_level"

# Step 4: Probe Templates
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/8: Destroying probe templates..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
destroy_resource "harness_chaos_probe_template.project_level"
destroy_resource "harness_chaos_probe_template.org_level"
destroy_resource "harness_chaos_probe_template.account_level"
destroy_resource "harness_chaos_probe_template.update_test_http"
destroy_resource "harness_chaos_probe_template.update_test_cmd"
destroy_resource "harness_chaos_probe_template.update_test_k8s"

# Step 5: Action Templates
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5/8: Destroying action templates..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
destroy_resource "harness_chaos_action_template.project_level"
destroy_resource "harness_chaos_action_template.org_level"
destroy_resource "harness_chaos_action_template.account_level"

# Step 6: Chaos Hubs (must be after all templates)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 6/8: Destroying chaos hubs..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
destroy_resource "harness_chaos_hub_v2.project_level"
destroy_resource "harness_chaos_hub_v2.org_level"
destroy_resource "harness_chaos_hub_v2.account_level"

# Step 7: Image Registries
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 7/8: Destroying image registries..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
destroy_resource "harness_chaos_image_registry.project_level"
destroy_resource "harness_chaos_image_registry.org_level"

# Step 8: Everything else
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 8/8: Destroying remaining resources..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
terraform destroy -auto-approve

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Cleanup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
