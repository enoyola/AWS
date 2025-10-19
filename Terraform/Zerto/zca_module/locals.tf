# Local values for computed expressions and complex logic

locals {
  # Common resource naming
  resource_prefix = "${var.name_prefix}-zca"
  
  # Common tags applied to all resources
  common_resource_tags = merge(var.common_tags, {
    Environment  = var.environment
    ManagedBy    = "Terraform"
    Module       = "zca_module"
    Application  = "Zerto"
  })
  
  # Security group rules for management access
  management_ingress_rules = [
    {
      description = "SSH access"
      port        = 22
      protocol    = "tcp"
    },
    {
      description = "HTTPS management access"
      port        = 443
      protocol    = "tcp"
    },
    {
      description = "HTTP management access (redirect to HTTPS)"
      port        = 80
      protocol    = "tcp"
    }
  ]
  
  # Security group rules for Zerto application ports
  zerto_application_ports = [
    {
      description = "Zerto Virtual Manager communication"
      port        = 9081
      protocol    = "tcp"
    },
    {
      description = "Zerto Cloud Connector communication"
      port        = 9071
      protocol    = "tcp"
    },
    {
      description = "Zerto replication traffic"
      port        = 4007
      protocol    = "tcp"
    },
    {
      description = "Zerto Analytics communication"
      port        = 9080
      protocol    = "tcp"
    }
  ]
}