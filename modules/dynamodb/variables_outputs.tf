variable "project"     { type = string }
variable "environment" { type = string }

output "main_table_name" { value = aws_dynamodb_table.posts.name }
output "stream_arn"      { value = aws_dynamodb_table.posts.stream_arn }
output "main_table_arn"  { value = aws_dynamodb_table.posts.arn }
