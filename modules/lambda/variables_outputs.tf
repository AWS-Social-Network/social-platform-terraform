variable "project"             { type = string }
variable "environment"         { type = string }
variable "lambda_role_arn"     { type = string }
variable "dynamodb_table_name"  { type = string }
variable "dynamodb_stream_arn"  { type = string }
variable "sqs_queue_url"       { type = string }
variable "localstack_endpoint" { type = string }
variable "ecr_repository_url"  { type = string }
variable "image_tag"          { 
    type = string 
    default = "latest"
}

output "processor_arn" { value = aws_lambda_function.stream_processor.arn }
