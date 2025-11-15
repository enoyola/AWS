# General Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = ""
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = ""
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# Security Group Variables
variable "web_ingress_cidrs" {
  description = "CIDR blocks allowed to access web tier"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "management_cidrs" {
  description = "CIDR blocks allowed for SSH/management access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "app_port" {
  description = "Port for application tier"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port for database"
  type        = number
  default     = 3306
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"  # Larger instance for production
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 2  # Minimum 2 for HA
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd amazon-cloudwatch-agent
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Production Server - $(hostname -f)</h1>" > /var/www/html/index.html
    
    # Configure CloudWatch agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux
  EOF
}

# RDS Variables
variable "create_rds" {
  description = "Create RDS instance"
  type        = bool
  default     = true  # Production typically needs database
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"  # Larger instance for production
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "myapp"
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 100  # More storage for production
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 1000
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 30  # Longer retention for production
}

variable "create_read_replica" {
  description = "Create a read replica"
  type        = bool
  default     = true
}

# S3 Variables
variable "create_s3" {
  description = "Create S3 bucket"
  type        = bool
  default     = true
}

variable "s3_lifecycle_rules" {
  description = "S3 lifecycle rules"
  type = list(object({
    id                                   = string
    enabled                             = bool
    prefix                              = string
    expiration_days                     = number
    noncurrent_version_expiration_days  = number
    transitions = list(object({
      days          = number
      storage_class = string
    }))
  }))
  default = [
    {
      id                                  = "production_lifecycle"
      enabled                            = true
      prefix                             = ""
      expiration_days                    = 0
      noncurrent_version_expiration_days = 90
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
    }
  ]
}

# Load Balancer Variables
variable "create_load_balancer" {
  description = "Create Application Load Balancer"
  type        = bool
  default     = true  # Production typically needs ALB
}

variable "alb_access_logs_enabled" {
  description = "Enable ALB access logs"
  type        = bool
  default     = true
}

variable "alb_access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = ""
}

variable "create_https_listener" {
  description = "Create HTTPS listener"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
  default     = ""
}

variable "http_redirect_to_https" {
  description = "Redirect HTTP to HTTPS"
  type        = bool
  default     = true
}