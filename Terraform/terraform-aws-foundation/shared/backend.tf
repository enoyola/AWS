# Shared backend configuration template
# Copy this to your environment directory and customize as needed

terraform {
  backend "s3" {
    # Replace with your actual values
    bucket         = "your-terraform-state-bucket"
    key            = "environment/terraform.tfstate"  # Change 'environment' to actual env name
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Optional: Use workspace for environment separation
    # workspace_key_prefix = "environments"
  }
}

# DynamoDB table for state locking (create this first)
# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = "terraform-state-lock"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"
#
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#
#   tags = {
#     Name        = "Terraform State Lock Table"
#     Environment = "shared"
#     ManagedBy   = "Terraform"
#   }
# }