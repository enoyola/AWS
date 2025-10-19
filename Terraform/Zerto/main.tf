terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "zca" {
  source = "./zca_module"
  
  # Example variable overrides
  # name_prefix = "prod-zca"
  # environment = "production"
  # vpc_cidr    = "10.1.0.0/16"
  # subnet_cidr = "10.1.1.0/24"
  
  # Security configuration
  # allowed_ssh_cidrs   = ["10.0.0.0/8"]
  # allowed_zerto_cidrs = ["192.168.0.0/16"]
  
  # Instance configuration  
  # instance_type = "m5.xlarge"
  # key_pair_name = "my-key-pair"
}

