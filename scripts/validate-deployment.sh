#!/bin/bash
# Validate E2E chaos deployment
# Runs automated checks to verify all resources were created correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "E2E Chaos Tests - Deployment Validation"
echo "=========================================="
echo ""

# Track failures
FAILURES=0
WARNINGS=0

# Function to validate
validate() {
    local description="$1"
    local condition="$2"
    
    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        FAILURES=$((FAILURES + 1))
        return 1
    fi
}

# Function to warn
warn() {
    local description="$1"
    local condition="$2"
    
    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $description"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

# 1. Check Terraform state exists
echo "Checking Terraform state..."
validate "Terraform state file exists" "[ -f terraform.tfstate ]"
echo ""

# 2. Count resources
echo "Checking resource count..."
RESOURCE_COUNT=$(terraform state list 2>/dev/null | wc -l | tr -d ' ')
validate "At least 30 resources created (found: $RESOURCE_COUNT)" "[ $RESOURCE_COUNT -ge 30 ]"
echo ""

# 3. Check foundation resources
echo "Checking foundation resources..."
validate "Organization created" "terraform state show harness_platform_organization.this &>/dev/null"
validate "Project created" "terraform state show harness_platform_project.this &>/dev/null"
validate "Kubernetes connector created" "terraform state show harness_platform_connector_kubernetes.this &>/dev/null"
echo ""

# 4. Check chaos hubs
echo "Checking chaos hubs..."
validate "Account-level hub created" "terraform state show harness_chaos_hub_v2.account_level &>/dev/null"
validate "Org-level hub created" "terraform state show harness_chaos_hub_v2.org_level &>/dev/null"
validate "Project-level hub created" "terraform state show harness_chaos_hub_v2.project_level &>/dev/null"
echo ""

# 5. Check templates
echo "Checking templates..."
validate "Account action template created" "terraform state show harness_chaos_action_template.account_level &>/dev/null"
validate "Account probe template created" "terraform state show harness_chaos_probe_template.account_level &>/dev/null"
validate "Account fault template created" "terraform state show harness_chaos_fault_template.account_level &>/dev/null"
validate "Org action template created" "terraform state show harness_chaos_action_template.org_level &>/dev/null"
validate "Org probe template created" "terraform state show harness_chaos_probe_template.org_level &>/dev/null"
validate "Org fault template created" "terraform state show harness_chaos_fault_template.org_level &>/dev/null"
validate "Project action template created" "terraform state show harness_chaos_action_template.project_level &>/dev/null"
validate "Project probe template created" "terraform state show harness_chaos_probe_template.project_level &>/dev/null"
validate "Project fault template created" "terraform state show harness_chaos_fault_template.project_level &>/dev/null"
echo ""

# 6. Check experiment templates
echo "Checking experiment templates..."
validate "Account experiment template created" "terraform state show 'harness_chaos_experiment_template.account_complex' &>/dev/null"
validate "Org experiment template created" "terraform state show 'harness_chaos_experiment_template.org_complex' &>/dev/null"
validate "Project experiment template created" "terraform state show 'harness_chaos_experiment_template.project_complex' &>/dev/null"
echo ""

# 7. Check infrastructure
echo "Checking infrastructure..."
validate "Environment created" "terraform state show harness_platform_environment.this &>/dev/null"
validate "Platform infrastructure created" "terraform state show harness_platform_infrastructure.this &>/dev/null"
validate "Chaos infrastructure created" "terraform state show harness_chaos_infrastructure_v2.this &>/dev/null"
validate "Service discovery agent created" "terraform state show harness_service_discovery_agent.this &>/dev/null"
echo ""

# 8. Check security governance
echo "Checking security governance..."
validate "Security condition created" "terraform state show harness_chaos_security_governance_condition.this &>/dev/null"
validate "Security rule created" "terraform state show harness_chaos_security_governance_rule.this &>/dev/null"
echo ""

# 9. Check experiments
echo "Checking experiments..."
validate "Project REFERENCE experiment created" "terraform state show harness_chaos_experiment.from_project_reference &>/dev/null"
validate "Project LOCAL experiment created" "terraform state show harness_chaos_experiment.from_project_local &>/dev/null"
warn "Org REFERENCE experiment created" "terraform state show harness_chaos_experiment.from_org_reference &>/dev/null"
warn "Org LOCAL experiment created" "terraform state show harness_chaos_experiment.from_org_local &>/dev/null"
warn "Account REFERENCE experiment created" "terraform state show harness_chaos_experiment.from_account_reference &>/dev/null"
warn "Account LOCAL experiment created" "terraform state show harness_chaos_experiment.from_account_local &>/dev/null"
echo ""

# 10. Check outputs
echo "Checking outputs..."
validate "Summary output available" "terraform output summary &>/dev/null"
validate "Organization ID output available" "terraform output org_id &>/dev/null"
validate "Project ID output available" "terraform output project_id &>/dev/null"
echo ""

# 11. Check for drift
echo "Checking for configuration drift..."
echo "Running terraform plan..."
if terraform plan -detailed-exitcode &>/dev/null; then
    echo -e "${GREEN}✓${NC} No drift detected - infrastructure matches configuration"
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 2 ]; then
        echo -e "${RED}✗${NC} Drift detected - infrastructure does not match configuration"
        echo "Run 'terraform plan' to see differences"
        FAILURES=$((FAILURES + 1))
    else
        echo -e "${RED}✗${NC} Error running terraform plan"
        FAILURES=$((FAILURES + 1))
    fi
fi
echo ""

# 12. Verify outputs contain expected data
echo "Validating output data..."
ORG_ID=$(terraform output -raw org_id 2>/dev/null || echo "")
PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || echo "")

validate "Organization ID is not empty" "[ -n '$ORG_ID' ]"
validate "Project ID is not empty" "[ -n '$PROJECT_ID' ]"
echo ""

# 13. Summary
echo "=========================================="
echo "Validation Summary:"
echo "  Resources checked: $RESOURCE_COUNT"
echo "  Failures: $FAILURES"
echo "  Warnings: $WARNINGS"
echo "=========================================="

if [ $FAILURES -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ All validation checks passed!${NC}"
        echo "Deployment is healthy and ready for use"
        exit 0
    else
        echo -e "${YELLOW}⚠ Validation passed with $WARNINGS warning(s)${NC}"
        echo "Deployment is functional but some optional resources may be missing"
        exit 0
    fi
else
    echo -e "${RED}✗ Validation failed with $FAILURES error(s)${NC}"
    echo "Please review the errors above and fix the deployment"
    exit 1
fi
