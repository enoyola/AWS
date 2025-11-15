output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "function_version" {
  description = "Version of the Lambda function"
  value       = aws_lambda_function.main.version
}

output "function_last_modified" {
  description = "Date the function was last modified"
  value       = aws_lambda_function.main.last_modified
}

output "function_source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = aws_lambda_function.main.source_code_hash
}

output "function_source_code_size" {
  description = "Size in bytes of the function .zip file"
  value       = aws_lambda_function.main.source_code_size
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "alias_arn" {
  description = "ARN of the Lambda alias"
  value       = var.create_alias ? aws_lambda_alias.main[0].arn : null
}

output "alias_invoke_arn" {
  description = "Invoke ARN of the Lambda alias"
  value       = var.create_alias ? aws_lambda_alias.main[0].invoke_arn : null
}

output "event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule"
  value       = var.create_event_rule ? aws_cloudwatch_event_rule.main[0].arn : null
}