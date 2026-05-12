variable "project" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_password" {
  type      = string
  sensitive = true
}

output "endpoint" { value = aws_db_instance.postgres.endpoint }
output "db_name" { value = aws_db_instance.postgres.db_name }
