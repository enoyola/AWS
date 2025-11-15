variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Role variables
variable "create_role" {
  description = "Create IAM role"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "default-role"
}

variable "assume_role_policy" {
  description = "Assume role policy document"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policies to attach to the role"
  type        = map(string)
  default     = {}
}

variable "create_instance_profile" {
  description = "Create IAM instance profile"
  type        = bool
  default     = false
}

# User variables
variable "create_user" {
  description = "Create IAM user"
  type        = bool
  default     = false
}

variable "user_name" {
  description = "Name of the IAM user"
  type        = string
  default     = "default-user"
}

variable "user_path" {
  description = "Path for the IAM user"
  type        = string
  default     = "/"
}

variable "user_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the user"
  type        = list(string)
  default     = []
}

variable "user_inline_policies" {
  description = "Map of inline policies to attach to the user"
  type        = map(string)
  default     = {}
}

variable "create_access_key" {
  description = "Create access key for the user"
  type        = bool
  default     = false
}

# Group variables
variable "create_group" {
  description = "Create IAM group"
  type        = bool
  default     = false
}

variable "group_name" {
  description = "Name of the IAM group"
  type        = string
  default     = "default-group"
}

variable "group_path" {
  description = "Path for the IAM group"
  type        = string
  default     = "/"
}

variable "group_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the group"
  type        = list(string)
  default     = []
}

# Policy variables
variable "create_policy" {
  description = "Create IAM policy"
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "default-policy"
}

variable "policy_path" {
  description = "Path for the IAM policy"
  type        = string
  default     = "/"
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "IAM policy created by Terraform"
}

variable "policy_document" {
  description = "IAM policy document"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}