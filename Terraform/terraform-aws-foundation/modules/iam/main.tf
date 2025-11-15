# IAM Role
resource "aws_iam_role" "main" {
  count = var.create_role ? 1 : 0

  name               = "${var.project_name}-${var.role_name}"
  assume_role_policy = var.assume_role_policy

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.role_name}"
  })
}

# IAM Role Policy Attachments
resource "aws_iam_role_policy_attachment" "managed_policies" {
  count = var.create_role ? length(var.managed_policy_arns) : 0

  role       = aws_iam_role.main[0].name
  policy_arn = var.managed_policy_arns[count.index]
}

# IAM Role Inline Policies
resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.create_role ? var.inline_policies : {}

  name   = each.key
  role   = aws_iam_role.main[0].id
  policy = each.value
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "main" {
  count = var.create_instance_profile && var.create_role ? 1 : 0

  name = "${var.project_name}-${var.role_name}-profile"
  role = aws_iam_role.main[0].name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.role_name}-profile"
  })
}

# IAM User
resource "aws_iam_user" "main" {
  count = var.create_user ? 1 : 0

  name = "${var.project_name}-${var.user_name}"
  path = var.user_path

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.user_name}"
  })
}

# IAM User Policy Attachments
resource "aws_iam_user_policy_attachment" "user_managed_policies" {
  count = var.create_user ? length(var.user_managed_policy_arns) : 0

  user       = aws_iam_user.main[0].name
  policy_arn = var.user_managed_policy_arns[count.index]
}

# IAM User Inline Policies
resource "aws_iam_user_policy" "user_inline_policies" {
  for_each = var.create_user ? var.user_inline_policies : {}

  name   = each.key
  user   = aws_iam_user.main[0].name
  policy = each.value
}

# IAM Access Key
resource "aws_iam_access_key" "main" {
  count = var.create_user && var.create_access_key ? 1 : 0

  user = aws_iam_user.main[0].name
}

# IAM Group
resource "aws_iam_group" "main" {
  count = var.create_group ? 1 : 0

  name = "${var.project_name}-${var.group_name}"
  path = var.group_path
}

# IAM Group Policy Attachments
resource "aws_iam_group_policy_attachment" "group_managed_policies" {
  count = var.create_group ? length(var.group_managed_policy_arns) : 0

  group      = aws_iam_group.main[0].name
  policy_arn = var.group_managed_policy_arns[count.index]
}

# IAM Group Membership
resource "aws_iam_group_membership" "main" {
  count = var.create_group && var.create_user ? 1 : 0

  name  = "${var.project_name}-group-membership"
  users = [aws_iam_user.main[0].name]
  group = aws_iam_group.main[0].name
}

# IAM Policy
resource "aws_iam_policy" "main" {
  count = var.create_policy ? 1 : 0

  name        = "${var.project_name}-${var.policy_name}"
  path        = var.policy_path
  description = var.policy_description
  policy      = var.policy_document

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.policy_name}"
  })
}