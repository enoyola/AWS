# Zerto Cloud Appliance (ZCA) Terraform Module

This Terraform module deploys a Zerto Cloud Appliance (ZCA) on AWS with proper security controls, networking configuration, and IAM permissions. The module follows infrastructure-as-code best practices while maintaining Zerto-specific requirements for AMI and IAM policies.

## Features

- **Complete Infrastructure Setup**: Creates VPC, subnet, security groups, and EC2 instance
- **Security-First Design**: Implements least-privilege security groups and proper network controls
- **Flexible Configuration**: Supports customizable CIDR blocks, instance types, and access controls
- **Zerto-Compliant**: Preserves required Zerto IAM policies and AMI specifications
- **Production-Ready**: Includes comprehensive tagging, monitoring, and lifecycle management

## Architecture

The module creates the following AWS resources:

- **Networking**: VPC, subnet, internet gateway, route table, and network interface
- **Security**: Two security groups (management and application-specific)
- **Compute**: EC2 instance with Zerto-specific AMI and configuration
- **IAM**: Policy, role, and instance profile with Zerto-required permissions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Usage

### Basic Usage

```hcl
module "zerto_zca" {
  source = "./zca_module"
  
  name_prefix = "prod-zca"
  environment = "production"
  
  # Network Configuration
  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.1.0/24"
  
  # Instance Configuration
  instance_type   = "m5.xlarge"
  key_pair_name   = "my-key-pair"
  
  # Security Configuration
  allowed_ssh_cidrs   = ["10.0.0.0/8", "192.168.1.0/24"]
  allowed_zerto_cidrs = ["10.0.0.0/8"]
  
  # Tagging
  common_tags = {
    Project     = "DR-Infrastructure"
    Owner       = "Platform-Team"
    Environment = "production"
    CostCenter  = "IT-Operations"
  }
}
```

### Advanced Usage with Custom Configuration

```hcl
module "zerto_zca_dev" {
  source = "./zca_module"
  
  # Environment-specific configuration
  name_prefix = "dev-zca"
  environment = "dev"
  aws_region  = "us-west-2"
  
  # Network Configuration
  vpc_cidr    = "172.16.0.0/16"
  subnet_cidr = "172.16.1.0/24"
  
  # Instance Configuration
  instance_type     = "t3.large"
  key_pair_name     = "dev-key-pair"
  enable_public_ip  = true
  
  # Security Configuration - More restrictive for dev
  allowed_ssh_cidrs   = ["203.0.113.0/24"]  # Office IP range
  allowed_zerto_cidrs = ["203.0.113.0/24"]
  
  # Custom AMI (if needed)
  zerto_ami_id = "ami-064893bdeb68e4c04"
  
  # Custom tagging
  common_tags = {
    Project     = "Zerto-Development"
    Owner       = "DevOps-Team"
    Environment = "development"
    AutoShutdown = "true"
  }
}
```

### Multi-Environment Deployment

```hcl
# Production Environment
module "zerto_zca_prod" {
  source = "./zca_module"
  
  name_prefix = "prod-zca"
  environment = "prod"
  
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
  
  instance_type = "m5.2xlarge"
  key_pair_name = "prod-zca-key"
  
  allowed_ssh_cidrs   = ["10.0.0.0/8"]
  allowed_zerto_cidrs = ["10.0.0.0/8", "172.16.0.0/12"]
  
  common_tags = {
    Project     = "Production-DR"
    Environment = "production"
    Criticality = "high"
  }
}

# Staging Environment
module "zerto_zca_staging" {
  source = "./zca_module"
  
  name_prefix = "staging-zca"
  environment = "staging"
  
  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.1.0/24"
  
  instance_type = "m5.large"
  key_pair_name = "staging-zca-key"
  
  allowed_ssh_cidrs   = ["10.0.0.0/8"]
  allowed_zerto_cidrs = ["10.0.0.0/8"]
  
  common_tags = {
    Project     = "Staging-DR"
    Environment = "staging"
    Criticality = "medium"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region for deployment | `string` | `"us-east-1"` | no |
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| subnet_cidr | CIDR block for the subnet | `string` | `"10.0.1.0/24"` | no |
| instance_type | EC2 instance type for the ZCA instance | `string` | `"m5.large"` | no |
| name_prefix | Prefix for resource names to ensure uniqueness and consistency | `string` | `"zca"` | no |
| environment | Environment tag for resource identification (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| common_tags | Map of common tags to apply to all resources | `map(string)` | `{"Project": "Zerto-ZCA", "ManagedBy": "Terraform"}` | no |
| allowed_ssh_cidrs | List of CIDR blocks allowed SSH access to the ZCA instance | `list(string)` | `[]` | no |
| allowed_zerto_cidrs | List of CIDR blocks allowed Zerto-specific access to the ZCA instance | `list(string)` | `[]` | no |
| zerto_ami_id | AMI ID for the Zerto Cloud Appliance (required by Zerto) | `string` | `"ami-064893bdeb68e4c04"` | no |
| enable_public_ip | Whether to assign a public IP address to the ZCA instance | `bool` | `true` | no |
| key_pair_name | Name of the AWS key pair for SSH access (optional) | `string` | `null` | no |

### Input Validation

The module includes comprehensive input validation:

- **CIDR Blocks**: All CIDR inputs are validated for proper IPv4 format
- **Instance Types**: Only validated EC2 instance types suitable for ZCA are allowed
- **Region Format**: AWS region must follow proper naming convention
- **Name Prefix**: Must be lowercase, alphanumeric with hyphens, max 20 characters
- **Environment**: Must be one of: dev, staging, test, prod, production
- **AMI ID**: Must follow AWS AMI identifier format

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the Zerto Cloud Appliance EC2 instance |
| instance_private_ip | The private IP address of the ZCA instance |
| instance_public_ip | The public IP address of the ZCA instance (if assigned) |
| instance_arn | The ARN of the ZCA EC2 instance |
| instance_availability_zone | The availability zone where the ZCA instance is deployed |
| vpc_id | The ID of the VPC where ZCA resources are deployed |
| vpc_cidr_block | The CIDR block of the VPC |
| subnet_id | The ID of the subnet where the ZCA instance is deployed |
| subnet_cidr_block | The CIDR block of the subnet |
| internet_gateway_id | The ID of the internet gateway for the VPC |
| route_table_id | The ID of the public route table |
| network_interface_id | The ID of the network interface attached to the ZCA instance |
| security_group_ids | List of security group IDs associated with the ZCA instance |
| management_security_group_id | The ID of the management security group for SSH and HTTPS access |
| application_security_group_id | The ID of the application security group for Zerto-specific ports |
| iam_role_arn | The ARN of the IAM role attached to the ZCA instance |
| iam_role_name | The name of the IAM role attached to the ZCA instance |
| iam_policy_arn | The ARN of the IAM policy with Zerto-specific permissions |
| iam_instance_profile_arn | The ARN of the IAM instance profile attached to the ZCA instance |
| iam_instance_profile_name | The name of the IAM instance profile attached to the ZCA instance |
| zca_management_url | The HTTPS URL for accessing the ZCA management interface |
| ssh_connection_command | SSH command to connect to the ZCA instance (requires key pair) |

## Security Groups

### Management Security Group
- **SSH (22)**: Access from `allowed_ssh_cidrs`
- **HTTP (80)**: Management interface access (redirects to HTTPS)
- **HTTPS (443)**: Secure management interface access
- **Egress**: All outbound traffic allowed

### Application Security Group
- **Port 9081**: Zerto Virtual Manager communication
- **Port 9071**: Zerto Cloud Connector communication
- **Port 4007**: Zerto replication traffic
- **Port 9080**: Zerto Analytics communication
- **Inter-ZCA**: Communication between ZCA instances in the same VPC
- **Egress**: All outbound traffic for Zerto cloud services

## Network Architecture

```
Internet Gateway
       |
   Route Table (Public)
       |
   Subnet (Public/Private based on enable_public_ip)
       |
   Network Interface
       |
   ZCA EC2 Instance
```

## IAM Permissions

The module creates IAM resources with Zerto-required permissions including:

- **EC2 Operations**: Instance management, volume operations, snapshot management
- **Networking**: Security group and network interface management
- **S3 Access**: Bucket operations for Zerto-prefixed buckets
- **CloudTrail**: Event logging and monitoring
- **SSM**: Systems Manager for instance management
- **EBS**: Enhanced block store operations for snapshots

## Deployment Instructions

### Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **AWS Key Pair created** (if SSH access is required)
4. **Network planning** completed (CIDR blocks, security requirements)

### Step-by-Step Deployment

1. **Clone or download the module**:
   ```bash
   git clone <repository-url>
   cd terraform-zca-module
   ```

2. **Create a Terraform configuration**:
   ```hcl
   # main.tf
   module "zerto_zca" {
     source = "./zca_module"
     
     name_prefix = "my-zca"
     environment = "production"
     
     # Configure as needed
     vpc_cidr    = "10.0.0.0/16"
     subnet_cidr = "10.0.1.0/24"
     
     allowed_ssh_cidrs   = ["YOUR_IP_RANGE/24"]
     allowed_zerto_cidrs = ["YOUR_ZERTO_NETWORK/24"]
     
     key_pair_name = "your-key-pair"
   }
   
   # outputs.tf
   output "zca_instance_id" {
     value = module.zerto_zca.instance_id
   }
   
   output "zca_management_url" {
     value = module.zerto_zca.zca_management_url
   }
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Access the ZCA**:
   - Use the output `zca_management_url` to access the web interface
   - Use the output `ssh_connection_command` for SSH access

### Post-Deployment Configuration

1. **Initial ZCA Setup**: Access the management URL and complete Zerto setup
2. **Network Connectivity**: Verify connectivity to your Zerto infrastructure
3. **Monitoring**: Set up CloudWatch monitoring for the instance
4. **Backup**: Configure backup strategies for the ZCA instance

## Best Practices

### Security
- Always specify `allowed_ssh_cidrs` and `allowed_zerto_cidrs` - never leave empty in production
- Use strong key pairs and rotate them regularly
- Enable CloudTrail for audit logging
- Regularly review and update security group rules

### Networking
- Plan CIDR blocks carefully to avoid conflicts
- Consider using private subnets for enhanced security
- Implement VPC Flow Logs for network monitoring
- Use VPC endpoints for AWS services when possible

### Operations
- Tag all resources consistently for cost tracking and management
- Use different name prefixes for different environments
- Implement proper backup and disaster recovery procedures
- Monitor instance health and performance metrics

### Cost Optimization
- Choose appropriate instance types based on workload requirements
- Use reserved instances for long-term deployments
- Implement auto-shutdown for development environments
- Monitor and optimize storage usage

## Troubleshooting

### Common Issues

1. **AMI Not Available**: Ensure the Zerto AMI is available in your target region
2. **CIDR Conflicts**: Verify CIDR blocks don't overlap with existing networks
3. **Security Group Rules**: Check that CIDR blocks in security groups are correct
4. **Key Pair**: Ensure the specified key pair exists in the target region
5. **IAM Permissions**: Verify Terraform has sufficient permissions to create resources

### Validation Commands

```bash
# Validate Terraform configuration
terraform validate

# Check formatting
terraform fmt -check

# Plan with detailed output
terraform plan -detailed-exitcode

# Verify instance is running
aws ec2 describe-instances --instance-ids <instance-id>

# Test connectivity
curl -k https://<instance-ip>
```

## Contributing

When contributing to this module:

1. Follow Terraform best practices and style guidelines
2. Update documentation for any new variables or outputs
3. Test changes in multiple environments
4. Ensure backward compatibility when possible
5. Update version constraints appropriately

## License

This module is provided as-is for Zerto Cloud Appliance deployment. Please refer to Zerto's licensing terms for the ZCA software itself.

## Support

For issues related to:
- **Terraform Module**: Create an issue in this repository
- **Zerto Software**: Contact Zerto support
- **AWS Infrastructure**: Refer to AWS documentation and support

---

**Note**: This module is designed to work with Zerto's specific requirements. Always verify compatibility with your Zerto version and AWS environment before deployment.