# Instance Outputs
output "instance_id" {
  description = "The ID of the Zerto Cloud Appliance EC2 instance"
  value       = aws_instance.zca_instance.id
}

output "instance_private_ip" {
  description = "The private IP address of the ZCA instance"
  value       = aws_instance.zca_instance.private_ip
}

output "instance_public_ip" {
  description = "The public IP address of the ZCA instance (if assigned)"
  value       = aws_instance.zca_instance.public_ip
}

output "instance_arn" {
  description = "The ARN of the ZCA EC2 instance"
  value       = aws_instance.zca_instance.arn
}

output "instance_availability_zone" {
  description = "The availability zone where the ZCA instance is deployed"
  value       = aws_instance.zca_instance.availability_zone
}

# Networking Outputs
output "vpc_id" {
  description = "The ID of the VPC where ZCA resources are deployed"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "subnet_id" {
  description = "The ID of the subnet where the ZCA instance is deployed"
  value       = aws_subnet.subnet.id
}

output "subnet_cidr_block" {
  description = "The CIDR block of the subnet"
  value       = aws_subnet.subnet.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway for the VPC"
  value       = aws_internet_gateway.gw.id
}

output "route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.rt_public.id
}

output "network_interface_id" {
  description = "The ID of the network interface attached to the ZCA instance"
  value       = aws_network_interface.zca_eni.id
}

# Security Group Outputs
output "security_group_ids" {
  description = "List of security group IDs associated with the ZCA instance"
  value = [
    aws_security_group.zca_management.id,
    aws_security_group.zca_application.id
  ]
}

output "management_security_group_id" {
  description = "The ID of the management security group for SSH and HTTPS access"
  value       = aws_security_group.zca_management.id
}

output "application_security_group_id" {
  description = "The ID of the application security group for Zerto-specific ports"
  value       = aws_security_group.zca_application.id
}

# IAM Outputs
output "iam_role_arn" {
  description = "The ARN of the IAM role attached to the ZCA instance"
  value       = aws_iam_role.zerto_role.arn
}

output "iam_role_name" {
  description = "The name of the IAM role attached to the ZCA instance"
  value       = aws_iam_role.zerto_role.name
}

output "iam_policy_arn" {
  description = "The ARN of the IAM policy with Zerto-specific permissions"
  value       = aws_iam_policy.zerto_policy.arn
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile attached to the ZCA instance"
  value       = aws_iam_instance_profile.zerto_profile.arn
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile attached to the ZCA instance"
  value       = aws_iam_instance_profile.zerto_profile.name
}

# Connection Information
output "zca_management_url" {
  description = "The HTTPS URL for accessing the ZCA management interface (if public IP is available)"
  value       = aws_instance.zca_instance.public_ip != null ? "https://${aws_instance.zca_instance.public_ip}" : "https://${aws_instance.zca_instance.private_ip}"
}

output "ssh_connection_command" {
  description = "SSH command to connect to the ZCA instance (requires key pair)"
  value       = aws_instance.zca_instance.public_ip != null ? "ssh -i /path/to/your/key.pem ec2-user@${aws_instance.zca_instance.public_ip}" : "ssh -i /path/to/your/key.pem ec2-user@${aws_instance.zca_instance.private_ip}"
}