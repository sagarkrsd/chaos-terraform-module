#!/bin/bash
# Drift testing for E2E chaos deployment
# Tests for configuration drift after deployment and after manual changes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "E2E Chaos Tests - Drift Testing"
echo "=========================================="
echo ""

# Track test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run drift test
drift_test() {
    local test_name="$1"
    local description="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${BLUE}Test $TESTS_RUN: $test_name${NC}"
    echo "  $description"
    
    # Run terraform plan and capture exit code
    if terraform plan -detailed-exitcode -out=drift-test.tfplan &>/dev/null; then
        echo -e "  ${GREEN}✓ PASSED${NC} - No drift detected"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        rm -f drift-test.tfplan
        return 0
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 2 ]; then
            echo -e "  ${RED}✗ FAILED${NC} - Drift detected"
            echo "  Run 'terraform plan' to see differences"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            rm -f drift-test.tfplan
            return 1
        else
            echo -e "  ${RED}✗ ERROR${NC} - Terraform plan failed"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            rm -f drift-test.tfplan
            return 1
        fi
    fi
}

# Function to show drift details
show_drift() {
    echo ""
    echo "Drift Details:"
    echo "----------------------------------------"
    terraform plan -no-color | head -50
    echo "----------------------------------------"
    echo ""
}

# Test 1: Initial drift check
echo "=========================================="
echo "Phase 1: Initial Drift Check"
echo "=========================================="
echo ""

drift_test \
    "Initial State Drift Check" \
    "Verify no drift exists immediately after deployment"

if [ $TESTS_FAILED -gt 0 ]; then
    show_drift
fi
echo ""

# Test 2: Re-apply and check
echo "=========================================="
echo "Phase 2: Re-apply Test"
echo "=========================================="
echo ""

echo "Running terraform apply (should be no-op)..."
if terraform apply -auto-approve &>/dev/null; then
    echo -e "${GREEN}✓${NC} Re-apply completed successfully"
else
    echo -e "${RED}✗${NC} Re-apply failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

drift_test \
    "Post Re-apply Drift Check" \
    "Verify no drift after re-applying configuration"

echo ""

# Test 3: Refresh state and check
echo "=========================================="
echo "Phase 3: State Refresh Test"
echo "=========================================="
echo ""

echo "Refreshing Terraform state..."
if terraform refresh &>/dev/null; then
    echo -e "${GREEN}✓${NC} State refresh completed successfully"
else
    echo -e "${RED}✗${NC} State refresh failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

drift_test \
    "Post Refresh Drift Check" \
    "Verify no drift after refreshing state from API"

echo ""

# Test 4: Check specific resource types for drift
echo "=========================================="
echo "Phase 4: Resource-Specific Drift Checks"
echo "=========================================="
echo ""

# Function to check specific resource drift
check_resource_drift() {
    local resource_address="$1"
    local resource_name="$2"
    
    if terraform state show "$resource_address" &>/dev/null; then
        # Check if this specific resource has drift
        if terraform plan -target="$resource_address" -detailed-exitcode &>/dev/null; then
            echo -e "${GREEN}✓${NC} $resource_name - No drift"
            return 0
        else
            echo -e "${RED}✗${NC} $resource_name - Drift detected"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} $resource_name - Resource not found"
        return 1
    fi
}

echo "Checking individual resource types for drift..."
check_resource_drift "harness_platform_organization.this" "Organization"
check_resource_drift "harness_platform_project.this" "Project"
check_resource_drift "harness_chaos_hub_v2.account_level" "Account Hub"
check_resource_drift "harness_chaos_hub_v2.org_level" "Org Hub"
check_resource_drift "harness_chaos_hub_v2.project_level" "Project Hub"
check_resource_drift "harness_chaos_action_template.account_level" "Account Action Template"
check_resource_drift "harness_chaos_probe_template.account_level" "Account Probe Template"
check_resource_drift "harness_chaos_fault_template.account_level" "Account Fault Template"
check_resource_drift "harness_chaos_infrastructure_v2.this" "Chaos Infrastructure"
check_resource_drift "harness_chaos_experiment.from_project_reference" "Project Experiment (REFERENCE)"
check_resource_drift "harness_chaos_experiment.from_project_local" "Project Experiment (LOCAL)"
echo ""

# Test 5: Check computed fields stability
echo "=========================================="
echo "Phase 5: Computed Fields Stability"
echo "=========================================="
echo ""

echo "Checking if computed fields are stable..."

# Get current state
CURRENT_ORG_ID=$(terraform output -raw org_id 2>/dev/null || echo "")
CURRENT_PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || echo "")

# Refresh and check again
terraform refresh &>/dev/null

NEW_ORG_ID=$(terraform output -raw org_id 2>/dev/null || echo "")
NEW_PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || echo "")

if [ "$CURRENT_ORG_ID" = "$NEW_ORG_ID" ]; then
    echo -e "${GREEN}✓${NC} Organization ID stable: $CURRENT_ORG_ID"
else
    echo -e "${RED}✗${NC} Organization ID changed: $CURRENT_ORG_ID → $NEW_ORG_ID"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if [ "$CURRENT_PROJECT_ID" = "$NEW_PROJECT_ID" ]; then
    echo -e "${GREEN}✓${NC} Project ID stable: $CURRENT_PROJECT_ID"
else
    echo -e "${RED}✗${NC} Project ID changed: $CURRENT_PROJECT_ID → $NEW_PROJECT_ID"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

# Test 6: Import type stability check
echo "=========================================="
echo "Phase 6: Import Type Stability"
echo "=========================================="
echo ""

echo "Checking REFERENCE vs LOCAL import behavior..."

# Check REFERENCE import (should track template changes)
if terraform state show harness_chaos_experiment.from_project_reference &>/dev/null; then
    IMPORT_TYPE=$(terraform state show harness_chaos_experiment.from_project_reference | grep "import_type" | awk '{print $3}' | tr -d '"')
    if [ "$IMPORT_TYPE" = "REFERENCE" ]; then
        echo -e "${GREEN}✓${NC} REFERENCE import type preserved"
    else
        echo -e "${RED}✗${NC} REFERENCE import type changed to: $IMPORT_TYPE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi

# Check LOCAL import (should have manifest)
if terraform state show harness_chaos_experiment.from_project_local &>/dev/null; then
    IMPORT_TYPE=$(terraform state show harness_chaos_experiment.from_project_local | grep "import_type" | awk '{print $3}' | tr -d '"')
    if [ "$IMPORT_TYPE" = "LOCAL" ]; then
        echo -e "${GREEN}✓${NC} LOCAL import type preserved"
    else
        echo -e "${RED}✗${NC} LOCAL import type changed to: $IMPORT_TYPE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
fi
echo ""

# Test 7: Tags stability
echo "=========================================="
echo "Phase 7: Tags Stability"
echo "=========================================="
echo ""

echo "Checking if tags are stable (lifecycle ignore_changes)..."

# Tags should be ignored in lifecycle, so no drift expected
drift_test \
    "Tags Stability Check" \
    "Verify tags don't cause drift (lifecycle ignore_changes)"

echo ""

# Summary
echo "=========================================="
echo "Drift Testing Summary"
echo "=========================================="
echo "  Tests Run: $TESTS_RUN"
echo "  Tests Passed: $TESTS_PASSED"
echo "  Tests Failed: $TESTS_FAILED"
echo "=========================================="

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All drift tests passed!${NC}"
    echo "Infrastructure is stable with no configuration drift"
    exit 0
else
    echo -e "${RED}✗ $TESTS_FAILED drift test(s) failed${NC}"
    echo "Review the failures above and investigate drift causes"
    echo ""
    echo "Common causes of drift:"
    echo "  - API returning different values than configured"
    echo "  - Computed fields not properly set in state"
    echo "  - Missing lifecycle ignore_changes for volatile fields"
    echo "  - Manual changes made in Harness UI"
    exit 1
fi
