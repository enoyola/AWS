# AWS Terraform Foundation Setup Guide

This guide will help you set up and deploy the AWS Terraform Foundation for your projects.

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS Account** with necessary permissions
4. **S3 Bucket** for Terraform state (for staging/prod)
5. **DynamoDB Table** for state locking (optional but recommended)

## Quick Start

### 1. Clone and Navigate
```bash
cd terraform-aws-foundation
```

### 2. Choose Your Environment
Start with the development environment for testing:
```bash
cd environments/dev
```

### 3. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 4. Deploy
```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

## Detailed Setup

### Step 1: Configure AWS Credentials

Ensure your AWS credentials are configured:
```bash
aws configure
# or use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"
```

### Step 2: Create State Management Resources (Production)

For production and staging environments, create an S3 bucket and DynamoDB table for state management:

```bash
# Create S3 bucket for state
aws s3 mb s3://your-terraform-state-bucket-prod --region us-west-2

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket-prod \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
```

### Step 3: Environment-Specific Configuration

#### Development Environment
- Uses local state by default
- Minimal resources for cost optimization
- Public subnets for easy access
- No deletion protection

#### Staging Environment
- Remote state in S3
- Similar to production but smaller instances
- Good for testing production-like deployments

#### Production Environment
- Remote state with locking
- High availability (multi-AZ)
- Enhanced monitoring and logging
- Deletion protection enabled
- Larger instance sizes

### Step 4: Customize Your Deployment

Edit the `terraform.tfvars` file in your chosen environment:

```hcl
# Required variables
project_name = "myproject"
aws_region   = "us-west-2"

# Optional but recommended
owner       = "DevOps Team"
cost_center = "Engineering"

# Infrastructure settings
create_rds           = true
create_s3            = true
create_load_balancer = true

# Security settings
key_name = "my-key-pair"  # Your EC2 key pair name
management_cidrs = ["192.168.1.0/24"]  # Your office IP range
```

## Module Usage

### Using Individual Modules

You can use individual modules in your own configurations:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name         = "myproject"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  common_tags = {
    Environment = "dev"
    Project     = "myproject"
  }
}
```

### Available Modules

- **VPC**: Complete VPC setup with public/private subnets, NAT gateways
- **Security Groups**: Layered security groups for web, app, and database tiers
- **EC2**: Launch templates, Auto Scaling Groups, or individual instances
- **RDS**: MySQL/PostgreSQL databases with backup and monitoring
- **S3**: Buckets with lifecycle policies and security settings
- **IAM**: Roles, policies, and instance profiles
- **Load Balancer**: Application Load Balancer with health checks
- **Lambda**: Functions with CloudWatch integration

## Deployment Scripts

Use the provided deployment script for easier management:

```bash
# Make script executable
chmod +x scripts/deploy.sh

# Deploy to development
./scripts/deploy.sh dev plan
./scripts/deploy.sh dev apply

# Deploy to production
./scripts/deploy.sh prod plan
./scripts/deploy.sh prod apply

# Validate all configurations
chmod +x scripts/validate-all.sh
./scripts/validate-all.sh
```

## Best Practices Implemented

### Security
- Private subnets for application and database tiers
- Security groups with least privilege access
- Encryption enabled by default
- IAM roles with minimal required permissions

### High Availability
- Multi-AZ deployments
- Auto Scaling Groups
- Load balancer health checks
- Database backups and read replicas

### Cost Optimization
- Right-sized instances for each environment
- S3 lifecycle policies
- Spot instances support (configurable)
- Resource tagging for cost allocation

### Operational Excellence
- Comprehensive monitoring and logging
- Infrastructure as Code
- Environment separation
- Automated deployments

## Troubleshooting

### Common Issues

1. **State Lock Errors**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Permission Errors**
   - Ensure your AWS credentials have necessary permissions
   - Check IAM policies for Terraform operations

3. **Resource Conflicts**
   - Use unique project names
   - Check for existing resources with same names

4. **Module Not Found**
   - Ensure you're running from the correct directory
   - Check module source paths

### Getting Help

1. Check the module README files for specific configuration options
2. Review AWS documentation for service-specific requirements
3. Use `terraform plan` to preview changes before applying
4. Enable debug logging: `export TF_LOG=DEBUG`

## Customization

### Adding New Modules

1. Create module directory under `modules/`
2. Follow the standard structure: `main.tf`, `variables.tf`, `outputs.tf`
3. Add module documentation
4. Update environment configurations to use the new module

### Modifying Existing Modules

1. Update the module files
2. Test in development environment first
3. Update version constraints if needed
4. Document breaking changes

## Security Considerations

- Store sensitive values in AWS Secrets Manager or Parameter Store
- Use IAM roles instead of access keys where possible
- Enable CloudTrail for audit logging
- Regularly rotate credentials
- Use least privilege access principles
- Enable MFA for production access

## Cost Management

- Use AWS Cost Explorer to monitor spending
- Set up billing alerts
- Tag all resources consistently
- Review and optimize instance sizes regularly
- Use Reserved Instances for predictable workloads
- Implement auto-scaling to match demand

## Next Steps

1. Deploy to development environment
2. Test your application deployment
3. Set up CI/CD pipeline integration
4. Configure monitoring and alerting
5. Plan production deployment
6. Set up backup and disaster recovery procedures