variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "filename" {
  description = "Path to the function's deployment package"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "ARN of the IAM role for Lambda function"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role for Lambda function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
  validation {
    condition = contains([
      "nodejs18.x", "nodejs16.x", "nodejs14.x",
      "python3.9", "python3.8", "python3.7",
      "java17", "java11", "java8",
      "dotnet6", "dotnetcore3.1",
      "go1.x", "ruby2.7", "provided.al2"
    ], var.runtime)
    error_message = "Runtime must be a valid Lambda runtime."
  }
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 3
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC configuration"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for VPC configuration"
  type        = list(string)
  default     = []
}

variable "dead_letter_target_arn" {
  description = "ARN of the dead letter queue or topic"
  type        = string
  default     = ""
}

variable "tracing_mode" {
  description = "Tracing mode for X-Ray"
  type        = string
  default     = ""
  validation {
    condition     = var.tracing_mode == "" || contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "Tracing mode must be either Active or PassThrough."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "allow_api_gateway" {
  description = "Allow API Gateway to invoke the function"
  type        = bool
  default     = false
}

variable "api_gateway_source_arn" {
  description = "Source ARN for API Gateway permission"
  type        = string
  default     = ""
}

variable "allow_s3" {
  description = "Allow S3 to invoke the function"
  type        = bool
  default     = false
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for permission"
  type        = string
  default     = ""
}

variable "allow_cloudwatch_events" {
  description = "Allow CloudWatch Events to invoke the function"
  type        = bool
  default     = false
}

variable "cloudwatch_event_rule_arn" {
  description = "CloudWatch Event Rule ARN for permission"
  type        = string
  default     = ""
}

variable "create_alias" {
  description = "Create a Lambda alias"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "Name of the Lambda alias"
  type        = string
  default     = "live"
}

variable "alias_description" {
  description = "Description of the Lambda alias"
  type        = string
  default     = ""
}

variable "function_version" {
  description = "Lambda function version for alias"
  type        = string
  default     = "$LATEST"
}

variable "additional_version_weights" {
  description = "Additional version weights for alias routing"
  type        = map(number)
  default     = null
}

variable "create_event_rule" {
  description = "Create CloudWatch Event Rule"
  type        = bool
  default     = false
}

variable "event_rule_description" {
  description = "Description of the CloudWatch Event Rule"
  type        = string
  default     = ""
}

variable "schedule_expression" {
  description = "Schedule expression for the event rule"
  type        = string
  default     = ""
}

variable "event_pattern" {
  description = "Event pattern for the event rule"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}