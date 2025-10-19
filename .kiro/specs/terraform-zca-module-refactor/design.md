# Design Document

## Overview

This design outlines the refactoring of the Zerto Cloud Appliance (ZCA) Terraform module to follow infrastructure-as-code best practices. The refactored module will maintain the existing Zerto-specific IAM policy and AMI requirements while improving modularity, security, and maintainability through proper file organization, variable inputs, outputs, and enhanced networking security.

## Architecture

### Module Structure
The refactored module will follow standard Terraform module conventions:

```
zca_module/
├── main.tf          # Main resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value definitions
├── versions.tf      # Provider version constraints
└── README.md        # Module documentation
```

### Resource Organization
Resources will be logically grouped in main.tf:
1. **IAM Resources**: Policy, role, instance profile (preserved as-is)
2. **Networking Resources**: VPC, subnet, internet gateway, route table, security groups
3. **Compute Resources**: EC2 instance with proper configuration

## Components and Interfaces

### Input Variables (variables.tf)
- `aws_region`: AWS region for deployment (default: "us-east-1")
- `vpc_cidr`: CIDR block for VPC (default: "10.0.0.0/16")
- `subnet_cidr`: CIDR block for subnet (default: "10.0.1.0/24")
- `instance_type`: EC2 instance type (default: "m5.large")
- `name_prefix`: Prefix for resource names (default: "zca")
- `environment`: Environment tag (default: "dev")
- `common_tags`: Map of common tags to apply to all resources
- `allowed_ssh_cidrs`: List of CIDR blocks allowed SSH access (default: [])
- `allowed_zerto_cidrs`: List of CIDR blocks allowed Zerto-specific access

### Security Groups Design
Two security groups will be created:
1. **ZCA Management Security Group**: For SSH and management access
2. **ZCA Application Security Group**: For Zerto-specific ports and protocols

### Networking Enhancements
- VPC with DNS support enabled
- Subnet with automatic availability zone selection
- Internet gateway for public connectivity
- Route table with proper internet routing
- Network interface with dynamic IP assignment

### Output Values (outputs.tf)
- `instance_id`: EC2 instance identifier
- `instance_private_ip`: Private IP address of the instance
- `instance_public_ip`: Public IP address (if assigned)
- `vpc_id`: VPC identifier
- `subnet_id`: Subnet identifier
- `security_group_ids`: List of security group IDs
- `iam_role_arn`: ARN of the IAM role

## Data Models

### Variable Validation
Input variables will include validation rules:
- CIDR blocks must be valid IPv4 CIDR notation
- Instance type must be a valid EC2 instance type
- Region must be a valid AWS region
- Name prefix must follow AWS naming conventions

### Tagging Strategy
All resources will receive consistent tags:
```hcl
{
  Name        = "${var.name_prefix}-${resource_type}"
  Environment = var.environment
  Project     = "Zerto-ZCA"
  ManagedBy   = "Terraform"
}
```

## Error Handling

### Input Validation
- Variable validation blocks will catch invalid inputs at plan time
- CIDR block validation to prevent network conflicts
- Instance type validation against available types

### Resource Dependencies
- Explicit dependencies will be defined where implicit dependencies are insufficient
- Proper resource ordering to prevent creation failures

### Provider Configuration
- Provider version constraints will be specified
- Required provider configuration will be documented

## Testing Strategy

### Module Validation
- `terraform validate` for syntax validation
- `terraform plan` for resource planning verification
- Variable validation testing with various input combinations

### Integration Testing
- Deploy in test environment to verify functionality
- Validate all outputs are correctly populated
- Confirm security group rules are properly applied
- Test instance connectivity and Zerto functionality

### Documentation Testing
- README examples should be tested for accuracy
- Variable descriptions should be comprehensive
- Output descriptions should be clear and useful

## Implementation Notes

### Preserved Components
The following will remain unchanged as per Zerto requirements:
- Complete IAM policy JSON (aws_iam_policy.zerto_policy)
- AMI ID specification (ami-064893bdeb68e4c04)
- Core IAM role and instance profile structure

### Enhanced Components
- Security groups with specific Zerto port requirements
- Flexible networking with configurable CIDR blocks
- Comprehensive tagging across all resources
- Dynamic availability zone selection
- Proper resource naming conventions

### Best Practices Implementation
- Use of data sources where appropriate
- Consistent formatting and indentation
- Meaningful resource and variable names
- Comprehensive documentation
- Version constraints for providers