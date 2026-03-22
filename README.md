# AWS Repository

This repository groups together AWS automation assets used for infrastructure provisioning and operational tasks.

## Repository Structure

### `Terraform/`

Infrastructure as code for AWS deployments.

- `terraform-aws-foundation/`: reusable Terraform modules and environment layouts for common AWS infrastructure.
- `Zerto/`: Terraform assets related to Zerto Cloud Appliance deployments.
- `validation-tools/`: helper scripts and checks for validating Terraform modules and outputs.

### `Lambda Functions/`

Python-based AWS Lambda scripts for operational automation. The current functions are focused on starting and stopping EC2 instances on a schedule.

See [Lambda Functions/README.md](/Users/enoyola/Documents/GitHub/AWS/Lambda%20Functions/README.md) for details.

### `IAM Policies/`

IAM policy documents that support the automation in this repository. The current policy grants the EC2 permissions required by the scheduling Lambdas.

See [IAM Policies/README.md](/Users/enoyola/Documents/GitHub/AWS/IAM%20Policies/README.md) for details.

## Current Use Cases

- Provision AWS environments with Terraform.
- Deploy Zerto-related infrastructure with Terraform modules.
- Schedule EC2 instance start and stop operations with Lambda plus IAM.
- Validate Terraform modules and outputs before deployment.

## Notes

- Several assets in this repository are templates or starting points and require environment-specific values before deployment.
- Review regions, instance IDs, CIDR ranges, naming, and IAM permissions before using any artifact in production.
