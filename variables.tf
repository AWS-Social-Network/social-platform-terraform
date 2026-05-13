###############################################################
# variables.tf — root
###############################################################

variable "project" {
  description = "Project name (used in resource naming)"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack unified endpoint"
  type        = string
  default     = "http://localhost:4566"
}

variable "domain_name" {
  description = "Base domain for Route 53 hosted zone"
  type        = string
  default     = "myapp.local"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  default     = "localstack_password_123"
}

variable "aws_account_id" {
  description = "AWS account ID (use '000000000000' for LocalStack)"
  type        = string
  default     = "000000000000"
}

variable "ghcr_pat" {
  description = "GitHub PAT with read:packages scope"
  type        = string
  sensitive   = true
}
