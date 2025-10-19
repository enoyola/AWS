# =============================================================================
# IAM RESOURCES
# =============================================================================
# IAM resources for Zerto Cloud Appliance including policy, role, and instance profile

resource "aws_iam_policy" "zerto_policy" {
  name        = "${var.name_prefix}-zca-policy"
  description = "IAM policy for Zerto Cloud Appliance with required AWS permissions"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/ZERTO_TAG": "ZERTO_VPC_RESOURCE"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "iam:GetPolicyVersion",
                "ec2:DescribeInstances",
                "cloudtrail:GetTrailStatus",
                "ec2:DescribeSnapshots",
                "ec2:DeleteVolume",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeInstanceTypes",
                "ec2:StartInstances",
                "iam:ListAttachedRolePolicies",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "cloudtrail:LookupEvents",
                "ec2:ModifyVolume",
                "ec2:CreateTags",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:DeleteNetworkInterface",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "cloudtrail:DescribeTrails",
                "ec2:CreateVolume",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeSubnets",
                "ec2:AttachVolume",
                "ec2:ImportVolume",
                "ec2:DeleteSnapshot",
                "ec2:DeleteTags",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeRegions",
                "iam:PassRole",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeAvailabilityZones",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateSnapshots",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeInstanceStatus",
                "ec2:TerminateInstances",
                "ec2:DetachNetworkInterface",
                "ec2:ImportInstance",
                "ec2:DescribeTags",
                "ec2:CancelConversionTask",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeImages",
                "iam:ListPolicyVersions",
                "s3:ListAllMyBuckets",
                "ec2:DescribeVpcs",
                "ec2:AttachNetworkInterface",
                "ec2:CancelImportTask",
                "ec2:DescribeConversionTasks",
                "ebs:ListSnapshotBlocks",
                "ebs:ListChangedBlocks",
                "ebs:GetSnapshotBlock",
                "ssm:*",
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObjectVersion",
                "s3:DeleteObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::zerto*/*"
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketMultipartUploads",
                "s3:PutBucketTagging",
                "s3:PutLifecycleConfiguration",
                "s3:ListBucketVersions",
                "s3:CreateBucket",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:DeleteBucket",
                "s3:GetBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::zerto*"
        }
    ]
})

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-zca-policy"
    Environment = var.environment
    Purpose     = "Zerto ZCA IAM Policy"
    ResourceType = "IAM Policy"
  })
}


resource "aws_iam_role" "zerto_role" {
  name        = "${var.name_prefix}-zca-role"
  description = "IAM role for Zerto Cloud Appliance EC2 instance"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-zca-role"
    Environment = var.environment
    Purpose     = "Zerto ZCA IAM Role"
    ResourceType = "IAM Role"
  })
}

resource "aws_iam_role_policy_attachment" "zerto_role_attachment" {
  role       = aws_iam_role.zerto_role.name
  policy_arn = aws_iam_policy.zerto_policy.arn
}

resource "aws_iam_instance_profile" "zerto_profile" {
  name = "${var.name_prefix}-zca-instance-profile"
  role = aws_iam_role.zerto_role.name

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-zca-instance-profile"
    Environment = var.environment
    Purpose     = "Zerto ZCA Instance Profile"
    ResourceType = "IAM Instance Profile"
  })
}

# =============================================================================
# NETWORKING RESOURCES
# =============================================================================
# VPC, subnets, internet gateway, route tables, and security groups for ZCA

# Data source to get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC with DNS support and configurable CIDR
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-vpc"
    Environment = var.environment
    Purpose     = "Zerto ZCA VPC"
  })
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.enable_public_ip

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-subnet"
    Environment = var.environment
    Purpose     = "Zerto ZCA Subnet"
  })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-igw"
    Environment = var.environment
    Purpose     = "Zerto ZCA Internet Gateway"
  })
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-rt-public"
    Environment = var.environment
    Purpose     = "Zerto ZCA Public Route Table"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt_public.id
}

# Security Groups for network access control
resource "aws_security_group" "zca_management" {
  name_prefix = "${var.name_prefix}-management-"
  description = "Security group for ZCA management access (SSH, HTTPS)"
  vpc_id      = aws_vpc.vpc.id

  # SSH access from allowed CIDR blocks
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? var.allowed_ssh_cidrs : []
    content {
      description = "SSH access from ${ingress.value}"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # HTTPS access for management interface
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? var.allowed_ssh_cidrs : []
    content {
      description = "HTTPS management access from ${ingress.value}"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # HTTP access for management interface (redirect to HTTPS)
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? var.allowed_ssh_cidrs : []
    content {
      description = "HTTP management access from ${ingress.value}"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Outbound internet access for updates and communication
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-management-sg"
    Environment = var.environment
    Purpose     = "ZCA Management Access"
  })
}

resource "aws_security_group" "zca_application" {
  name_prefix = "${var.name_prefix}-application-"
  description = "Security group for Zerto application-specific ports"
  vpc_id      = aws_vpc.vpc.id

  # Zerto Virtual Manager communication (port 9081)
  dynamic "ingress" {
    for_each = length(var.allowed_zerto_cidrs) > 0 ? var.allowed_zerto_cidrs : []
    content {
      description = "Zerto Virtual Manager communication from ${ingress.value}"
      from_port   = 9081
      to_port     = 9081
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Zerto Cloud Connector communication (port 9071)
  dynamic "ingress" {
    for_each = length(var.allowed_zerto_cidrs) > 0 ? var.allowed_zerto_cidrs : []
    content {
      description = "Zerto Cloud Connector communication from ${ingress.value}"
      from_port   = 9071
      to_port     = 9071
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Zerto replication traffic (port 4007)
  dynamic "ingress" {
    for_each = length(var.allowed_zerto_cidrs) > 0 ? var.allowed_zerto_cidrs : []
    content {
      description = "Zerto replication traffic from ${ingress.value}"
      from_port   = 4007
      to_port     = 4007
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Zerto Analytics communication (port 9080)
  dynamic "ingress" {
    for_each = length(var.allowed_zerto_cidrs) > 0 ? var.allowed_zerto_cidrs : []
    content {
      description = "Zerto Analytics communication from ${ingress.value}"
      from_port   = 9080
      to_port     = 9080
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Allow communication between ZCA instances in the same VPC
  ingress {
    description     = "Inter-ZCA communication within VPC"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.zca_management.id]
  }

  # Outbound internet access for Zerto cloud services
  egress {
    description = "All outbound traffic for Zerto services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-application-sg"
    Environment = var.environment
    Purpose     = "Zerto Application Access"
  })
}

# =============================================================================
# COMPUTE RESOURCES
# =============================================================================
# EC2 instance and network interface for Zerto Cloud Appliance

resource "aws_network_interface" "zca_eni" {
  subnet_id       = aws_subnet.subnet.id
  security_groups = [
    aws_security_group.zca_management.id,
    aws_security_group.zca_application.id
  ]

  tags = merge(var.common_tags, {
    Name        = "${var.name_prefix}-eni"
    Environment = var.environment
    Purpose     = "Zerto ZCA Network Interface"
  })
}

resource "aws_instance" "zca_instance" {
  ami                  = var.zerto_ami_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.zerto_profile.name
  key_name             = var.key_pair_name

  network_interface {
    network_interface_id = aws_network_interface.zca_eni.id
    device_index         = 0
  }

  # Enable detailed monitoring for better observability
  monitoring = true

  # Disable source/destination check for Zerto functionality
  source_dest_check = false

  tags = merge(var.common_tags, {
    Name         = "${var.name_prefix}-zca-instance"
    Environment  = var.environment
    Purpose      = "Zerto Cloud Appliance"
    ResourceType = "EC2 Instance"
    Application  = "Zerto"
  })

  lifecycle {
    # Prevent accidental termination of the ZCA instance
    prevent_destroy = true
    
    # Ignore changes to AMI after initial deployment to prevent unwanted updates
    ignore_changes = [ami]
  }
}