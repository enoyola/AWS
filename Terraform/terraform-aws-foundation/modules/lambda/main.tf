# Lambda Function
resource "aws_lambda_function" "main" {
  filename         = var.filename
  function_name    = "${var.project_name}-${var.function_name}"
  role            = var.role_arn
  handler         = var.handler
  source_code_hash = var.filename != "" ? filebase64sha256(var.filename) : null
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size
  description     = var.description

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != "" ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_mode != "" ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.function_name}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.function_name}-logs"
  })
}

# IAM policy for logging
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.project_name}-${var.function_name}-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.function_name}-logging-policy"
  })
}

# Attach logging policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = var.role_name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  count = var.allow_api_gateway ? 1 : 0

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.api_gateway_source_arn
}

# Lambda Permission for S3
resource "aws_lambda_permission" "s3" {
  count = var.allow_s3 ? 1 : 0

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "cloudwatch_events" {
  count = var.allow_cloudwatch_events ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.cloudwatch_event_rule_arn
}

# Lambda Alias
resource "aws_lambda_alias" "main" {
  count = var.create_alias ? 1 : 0

  name             = var.alias_name
  description      = var.alias_description
  function_name    = aws_lambda_function.main.function_name
  function_version = var.function_version

  dynamic "routing_config" {
    for_each = var.additional_version_weights != null ? [1] : []
    content {
      additional_version_weights = var.additional_version_weights
    }
  }
}

# EventBridge Rule (CloudWatch Events)
resource "aws_cloudwatch_event_rule" "main" {
  count = var.create_event_rule ? 1 : 0

  name                = "${var.project_name}-${var.function_name}-rule"
  description         = var.event_rule_description
  schedule_expression = var.schedule_expression
  event_pattern       = var.event_pattern

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.function_name}-rule"
  })
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "lambda" {
  count = var.create_event_rule ? 1 : 0

  rule      = aws_cloudwatch_event_rule.main[0].name
  target_id = "TargetId${aws_lambda_function.main.function_name}"
  arn       = aws_lambda_function.main.arn
}