#!/bin/bash
# Pre-flight checks for E2E chaos tests
# Verifies all prerequisites before running terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "E2E Chaos Tests - Pre-flight Checks"
echo "=========================================="
echo ""

# Track failures
FAILURES=0

# Function to check command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        FAILURES=$((FAILURES + 1))
        return 1
    fi
}

# Function to check environment variable
check_env_var() {
    if [ -n "${!1}" ]; then
        echo -e "${GREEN}✓${NC} $1 is set"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not set"
        FAILURES=$((FAILURES + 1))
        return 1
    fi
}

# 1. Check required commands
echo "Checking required commands..."
check_command terraform
check_command kubectl
check_command jq
echo ""

# 2. Check Terraform version
echo "Checking Terraform version..."
TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
REQUIRED_VERSION="1.0.0"
if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$TF_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
    echo -e "${GREEN}✓${NC} Terraform version $TF_VERSION (>= $REQUIRED_VERSION)"
else
    echo -e "${RED}✗${NC} Terraform version $TF_VERSION is too old (need >= $REQUIRED_VERSION)"
    FAILURES=$((FAILURES + 1))
fi
echo ""

# 3. Check environment variables
echo "Checking environment variables..."
check_env_var TF_VAR_harness_account_id
check_env_var TF_VAR_harness_platform_api_key
echo ""

# 4. Check terraform.tfvars exists
echo "Checking configuration files..."
if [ -f "terraform.tfvars" ]; then
    echo -e "${GREEN}✓${NC} terraform.tfvars exists"
    
    # Check required variables in tfvars
    if grep -q "delegate_selectors" terraform.tfvars; then
        echo -e "${GREEN}✓${NC} delegate_selectors configured"
    else
        echo -e "${YELLOW}⚠${NC} delegate_selectors not found in terraform.tfvars"
        FAILURES=$((FAILURES + 1))
    fi
else
    echo -e "${RED}✗${NC} terraform.tfvars not found"
    echo "  Run: cp terraform.tfvars.example terraform.tfvars"
    FAILURES=$((FAILURES + 1))
fi
echo ""

# 5. Check Kubernetes connectivity
echo "Checking Kubernetes connectivity..."
if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Kubernetes cluster is accessible"
    
    # Get cluster info
    CLUSTER_VERSION=$(kubectl version --short 2>/dev/null | grep "Server Version" | awk '{print $3}')
    echo "  Cluster version: $CLUSTER_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Kubernetes cluster not accessible"
    echo "  This is optional if delegate is already configured"
fi
echo ""

# 6. Check Harness API connectivity
echo "Checking Harness API connectivity..."
if [ -n "$TF_VAR_harness_account_id" ] && [ -n "$TF_VAR_harness_platform_api_key" ]; then
    HARNESS_ENDPOINT="${HARNESS_ENDPOINT:-https://app.harness.io/gateway}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "x-api-key: $TF_VAR_harness_platform_api_key" \
        "$HARNESS_ENDPOINT/ng/api/accounts/$TF_VAR_harness_account_id" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓${NC} Harness API is accessible"
    elif [ "$HTTP_CODE" = "401" ]; then
        echo -e "${RED}✗${NC} Harness API authentication failed (check API key)"
        FAILURES=$((FAILURES + 1))
    elif [ "$HTTP_CODE" = "000" ]; then
        echo -e "${YELLOW}⚠${NC} Cannot reach Harness API (check network)"
    else
        echo -e "${YELLOW}⚠${NC} Harness API returned HTTP $HTTP_CODE"
    fi
else
    echo -e "${YELLOW}⚠${NC} Skipping API check (credentials not set)"
fi
echo ""

# 7. Check disk space
echo "Checking disk space..."
AVAILABLE_SPACE=$(df -h . | awk 'NR==2 {print $4}')
echo "  Available space: $AVAILABLE_SPACE"
echo -e "${GREEN}✓${NC} Disk space check complete"
echo ""

# 8. Summary
echo "=========================================="
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}✓ All pre-flight checks passed!${NC}"
    echo "You can proceed with: terraform init && terraform apply"
    exit 0
else
    echo -e "${RED}✗ $FAILURES check(s) failed${NC}"
    echo "Please fix the issues above before proceeding"
    exit 1
fi
