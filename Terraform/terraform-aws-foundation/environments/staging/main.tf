terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Configure remote state for staging
  backend "s3" {
    bucket         = "your-terraform-state-bucket-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  environment = "staging"
  common_tags = {
    Environment   = local.environment
    Project       = var.project_name
    ManagedBy     = "Terraform"
    Owner         = var.owner
    CostCenter    = var.cost_center
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name           = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  enable_nat_gateway    = var.enable_nat_gateway
  common_tags           = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  project_name       = var.project_name
  vpc_id            = module.vpc.vpc_id
  web_ingress_cidrs = var.web_ingress_cidrs
  management_cidrs  = var.management_cidrs
  app_port          = var.app_port
  db_port           = var.db_port
  common_tags       = local.common_tags
}

# IAM Module for EC2
module "ec2_iam" {
  source = "../../modules/iam"

  project_name              = var.project_name
  create_role              = true
  role_name                = "ec2-role"
  create_instance_profile  = true
  assume_role_policy       = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  common_tags = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  project_name           = var.project_name
  instance_type         = var.instance_type
  key_name              = var.key_name
  subnet_ids            = var.ec2_in_public_subnets ? module.vpc.public_subnet_ids : module.vpc.private_subnet_ids
  security_group_ids    = [
    module.security_groups.app_security_group_id,
    module.security_groups.management_security_group_id
  ]
  instance_profile_name = module.ec2_iam.instance_profile_name
  create_asg           = var.create_asg
  instance_count       = var.instance_count
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
  target_group_arns    = var.create_load_balancer && var.create_asg ? [module.load_balancer[0].target_group_arn] : []
  health_check_type    = var.create_load_balancer && var.create_asg ? "ELB" : "EC2"
  user_data            = var.user_data
  common_tags          = local.common_tags
}

# RDS Module
module "rds" {
  count  = var.create_rds ? 1 : 0
  source = "../../modules/rds"

  project_name              = var.project_name
  engine                   = var.db_engine
  engine_version           = var.db_engine_version
  instance_class           = var.db_instance_class
  database_name            = var.database_name
  master_username          = var.db_master_username
  allocated_storage        = var.db_allocated_storage
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_ids      = [module.security_groups.database_security_group_id]
  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  common_tags             = local.common_tags
}

# S3 Module
module "s3" {
  count  = var.create_s3 ? 1 : 0
  source = "../../modules/s3"

  bucket_name        = "${var.project_name}-${local.environment}-${random_id.bucket_suffix.hex}"
  versioning_enabled = var.s3_versioning_enabled
  lifecycle_rules    = var.s3_lifecycle_rules
  common_tags        = local.common_tags
}

# Load Balancer Module
module "load_balancer" {
  count  = var.create_load_balancer ? 1 : 0
  source = "../../modules/load-balancer"

  project_name       = var.project_name
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.web_security_group_id]
  target_ids        = var.create_asg ? [] : module.ec2.instance_ids
  common_tags       = local.common_tags
}

# Random ID for unique resource names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}