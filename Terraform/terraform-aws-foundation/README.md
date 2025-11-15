# AWS Terraform Foundation

A comprehensive Terraform deployment structure for AWS with modular components following best practices.

## Structure

```
terraform-aws-foundation/
├── environments/          # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/              # Reusable Terraform modules
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   ├── s3/
│   ├── iam/
│   ├── security-groups/
│   ├── load-balancer/
│   └── lambda/
├── shared/               # Shared configurations
└── scripts/              # Helper scripts
```

## Usage

### Quick Start for New Client Deployments

1. **Choose your environment** (dev, staging, or prod)
   ```bash
   cd environments/dev  # or staging/prod
   ```

2. **Copy and customize the variables file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars with client-specific values**
   ```hcl
   # Essential variables
   project_name = "client-name"
   aws_region   = "us-east-1"
   key_name     = "client-key-pair"
   
   # Enable/disable services as needed
   create_rds           = true   # Set to false to omit RDS
   create_s3            = true   # Set to false to omit S3
   create_load_balancer = false  # Set to false to omit ALB
   create_asg           = false  # Set to false for individual instances
   
   # Customize sizing
   instance_type     = "t3.small"
   db_instance_class = "db.t3.micro"
   ```

4. **Deploy the infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Enabling/Disabling Services

**You don't need to edit main.tf files!** Simply use the boolean variables in `terraform.tfvars`:

- `create_rds = false` - Omit database
- `create_s3 = false` - Omit S3 bucket
- `create_load_balancer = false` - Omit Application Load Balancer
- `create_asg = false` - Use individual EC2 instances instead of Auto Scaling Group
- `create_read_replica = false` - Omit RDS read replica

**Example Scenarios:**

```hcl
# Simple web app without database
create_rds           = false
create_s3            = true
create_load_balancer = true

# Static website hosting
create_rds           = false
create_s3            = true
create_load_balancer = false
instance_count       = 0

# Database-heavy application
create_rds           = true
create_read_replica  = true
db_instance_class    = "db.t3.medium"
```

### When to Edit main.tf

You only need to modify `main.tf` files if you want to:
- Add completely new AWS services not already included
- Create custom module configurations beyond what variables allow
- Change module source paths for custom modules
- Add specific resource dependencies between modules

For standard deployments, **just edit terraform.tfvars** - that's it!

## Best Practices Implemented

- Modular architecture for reusability
- Environment separation
- Consistent naming conventions
- Proper variable validation
- Output values for module integration
- Remote state management ready
- Security-focused defaults