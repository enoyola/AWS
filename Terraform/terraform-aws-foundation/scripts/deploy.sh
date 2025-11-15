#!/bin/bash

# Terraform deployment script
# Usage: ./deploy.sh <environment> <action>
# Example: ./deploy.sh dev plan
# Example: ./deploy.sh prod apply

set -e

ENVIRONMENT=$1
ACTION=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <environment> <action>"
    echo "Environments: dev, staging, prod"
    echo "Actions: init, plan, apply, destroy, validate, fmt"
    exit 1
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "Error: Environment must be one of: dev, staging, prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(init|plan|apply|destroy|validate|fmt|show|output)$ ]]; then
    echo "Error: Action must be one of: init, plan, apply, destroy, validate, fmt, show, output"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    echo "Error: Environment directory $ENV_DIR does not exist"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "$ENV_DIR/terraform.tfvars" ] && [[ "$ACTION" =~ ^(plan|apply)$ ]]; then
    echo "Warning: terraform.tfvars not found in $ENV_DIR"
    echo "Please copy terraform.tfvars.example to terraform.tfvars and customize it"
    if [ ! -f "$ENV_DIR/terraform.tfvars.example" ]; then
        echo "Error: terraform.tfvars.example also not found"
        exit 1
    fi
    echo "Would you like to copy the example file? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cp "$ENV_DIR/terraform.tfvars.example" "$ENV_DIR/terraform.tfvars"
        echo "Please edit $ENV_DIR/terraform.tfvars before proceeding"
        exit 0
    else
        exit 1
    fi
fi

cd "$ENV_DIR"

echo "========================================="
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"
echo "Directory: $ENV_DIR"
echo "========================================="

case $ACTION in
    init)
        echo "Initializing Terraform..."
        terraform init
        ;;
    validate)
        echo "Validating Terraform configuration..."
        terraform validate
        ;;
    fmt)
        echo "Formatting Terraform files..."
        terraform fmt -recursive
        ;;
    plan)
        echo "Planning Terraform deployment..."
        terraform plan -out="tfplan-$ENVIRONMENT"
        ;;
    apply)
        if [ -f "tfplan-$ENVIRONMENT" ]; then
            echo "Applying Terraform plan..."
            terraform apply "tfplan-$ENVIRONMENT"
            rm -f "tfplan-$ENVIRONMENT"
        else
            echo "No plan file found. Running plan and apply..."
            terraform plan -out="tfplan-$ENVIRONMENT"
            echo "Do you want to apply this plan? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                terraform apply "tfplan-$ENVIRONMENT"
                rm -f "tfplan-$ENVIRONMENT"
            else
                echo "Apply cancelled"
                rm -f "tfplan-$ENVIRONMENT"
                exit 0
            fi
        fi
        ;;
    destroy)
        echo "WARNING: This will destroy all resources in $ENVIRONMENT environment!"
        echo "Are you sure you want to continue? (type 'yes' to confirm)"
        read -r response
        if [ "$response" = "yes" ]; then
            terraform destroy
        else
            echo "Destroy cancelled"
            exit 0
        fi
        ;;
    show)
        echo "Showing Terraform state..."
        terraform show
        ;;
    output)
        echo "Showing Terraform outputs..."
        terraform output
        ;;
    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac

echo "========================================="
echo "Action completed successfully!"
echo "========================================="