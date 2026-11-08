#!/usr/bin/env bash
# ==============================================================================
# Script: validate-prerequisites.sh
# Checks CLI dependencies and environment setup before applying Terraform
# ==============================================================================

set -uo pipefail

echo "===================================================================="
echo " Validating Spark on AWS EKS Prerequisites"
echo "===================================================================="

REQUIRED_TOOLS=("terraform" "aws" "kubectl" "helm")
MISSING_TOOLS=0

for tool in "${REQUIRED_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    case "$tool" in
      terraform)
        VERSION=$(terraform version | head -n 1)
        ;;
      aws)
        VERSION=$(aws --version 2>&1 | head -n 1)
        ;;
      kubectl)
        VERSION=$(kubectl version --client 2>&1 | head -n 1)
        ;;
      helm)
        VERSION=$(helm version --short 2>&1 | head -n 1)
        ;;
      *)
        VERSION="installed"
        ;;
    esac
    echo "✓ $tool found: $VERSION"
  else
    echo "✗ $tool is NOT installed or not in PATH"
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
  fi
done

if [ "$MISSING_TOOLS" -ne 0 ]; then
  echo ""
  echo "Error: Please install the missing tools listed above before continuing."
  exit 1
fi

echo ""
echo "Checking AWS Authentication..."
if aws sts get-caller-identity >/dev/null 2>&1; then
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  ARN=$(aws sts get-caller-identity --query Arn --output text)
  REGION=${AWS_REGION:-$(aws configure get region 2>/dev/null || echo "us-west-2")}
  echo "✓ AWS Authenticated as: $ARN"
  echo "✓ AWS Account ID: $ACCOUNT_ID"
  echo "✓ Target Region: $REGION"
else
  echo "! Warning: AWS credentials not configured or session expired."
  echo "  Please run 'aws configure' or export AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY."
fi

echo ""
echo "===================================================================="
echo " Prerequisites check completed."
echo "===================================================================="
