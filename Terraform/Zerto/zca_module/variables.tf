# Input Variables for Zerto Cloud Appliance (ZCA) Module


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
  
  validation {
    condition = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the ZCA instance"
  type        = string
  default     = "m5.large"
  
  validation {
    condition = contains([
      "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge",
      "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge",
      "m5.8xlarge", "m5.12xlarge", "m5.16xlarge", "m5.24xlarge",
      "c5.large", "c5.xlarge", "c5.2xlarge", "c5.4xlarge",
      "c5.9xlarge", "c5.12xlarge", "c5.18xlarge", "c5.24xlarge"
    ], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type suitable for ZCA deployment."
  }
}

variable "name_prefix" {
  description = "Prefix for resource names to ensure uniqueness and consistency"
  type        = string
  default     = "zca"
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.name_prefix)) && length(var.name_prefix) <= 20
    error_message = "Name prefix must start with a letter, contain only lowercase letters, numbers, and hyphens, and be 20 characters or less."
  }
}

variable "environment" {
  description = "Environment tag for resource identification (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition = contains(["dev", "staging", "test", "prod", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, test, prod, production."
  }
}

variable "common_tags" {
  description = "Map of common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "Zerto-ZCA"
    ManagedBy = "Terraform"
  }
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed SSH access to the ZCA instance"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_ssh_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All SSH CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "allowed_zerto_cidrs" {
  description = "List of CIDR blocks allowed Zerto-specific access to the ZCA instance"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_zerto_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All Zerto CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "zerto_ami_id" {
  description = "AMI ID for the Zerto Cloud Appliance (required by Zerto)"
  type        = string
  default     = "ami-064893bdeb68e4c04"
  
  validation {
    condition = can(regex("^ami-[0-9a-f]{8,17}$", var.zerto_ami_id))
    error_message = "AMI ID must be a valid AWS AMI identifier (ami-xxxxxxxx)."
  }
}

variable "enable_public_ip" {
  description = "Whether to assign a public IP address to the ZCA instance"
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for SSH access (optional)"
  type        = string
  default     = null
}