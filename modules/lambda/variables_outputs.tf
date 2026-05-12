variable "project" { type = string }
variable "environment" { type = string }
variable "repository_url" { type = string }
variable "lambda_role_arn" { type = string }
variable "dynamodb_table_name" { type = string }
variable "dynamodb_stream_arn" { type = string }
variable "sqs_queue_url" { type = string }
variable "sns_topic_arn" { type = string }
variable "rds_endpoint" { type = string }
variable "redis_endpoint" { type = string }

output "processor_arn" { value = aws_lambda_function.stream_processor.arn }
