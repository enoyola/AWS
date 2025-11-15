variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "web_ingress_cidrs" {
  description = "CIDR blocks allowed to access web tier"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "management_cidrs" {
  description = "CIDR blocks allowed for SSH/management access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "app_port" {
  description = "Port for application tier"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port for database"
  type        = number
  default     = 3306
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}