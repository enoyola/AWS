#!/bin/bash

# Script to validate all Terraform configurations
# Usage: ./validate-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Validating all Terraform configurations"
echo "========================================="

# Validate modules
echo "Validating modules..."
for module_dir in "$PROJECT_ROOT"/modules/*/; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "Validating module: $module_name"
        cd "$module_dir"
        terraform init -backend=false
        terraform validate
        terraform fmt -check
        echo "✓ Module $module_name is valid"
    fi
done

# Validate environments
echo ""
echo "Validating environments..."
for env_dir in "$PROJECT_ROOT"/environments/*/; do
    if [ -d "$env_dir" ]; then
        env_name=$(basename "$env_dir")
        echo "Validating environment: $env_name"
        cd "$env_dir"
        terraform init -backend=false
        terraform validate
        terraform fmt -check
        echo "✓ Environment $env_name is valid"
    fi
done

echo ""
echo "========================================="
echo "All validations completed successfully!"
echo "========================================="