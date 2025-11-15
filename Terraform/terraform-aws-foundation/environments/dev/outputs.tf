# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# Security Group Outputs
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.security_groups.web_security_group_id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.security_groups.app_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.security_groups.database_security_group_id
}

# EC2 Outputs
output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = module.ec2.instance_ids
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = module.ec2.instance_private_ips
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = module.ec2.instance_public_ips
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = module.ec2.autoscaling_group_id
}

# RDS Outputs
output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = var.create_rds ? module.rds[0].db_instance_endpoint : null
  sensitive   = true
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = var.create_rds ? module.rds[0].db_instance_port : null
}

# S3 Outputs
output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = var.create_s3 ? module.s3[0].bucket_id : null
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = var.create_s3 ? module.s3[0].bucket_arn : null
}

# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = var.create_load_balancer ? module.load_balancer[0].load_balancer_dns_name : null
}

output "load_balancer_zone_id" {
  description = "Hosted zone ID of the load balancer"
  value       = var.create_load_balancer ? module.load_balancer[0].load_balancer_zone_id : null
}

# IAM Outputs
output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = module.ec2_iam.role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.ec2_iam.instance_profile_name
}