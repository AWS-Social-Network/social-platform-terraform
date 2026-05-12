variable "project"     { type = string }
variable "environment" { type = string }

output "orders_queue_url" { value = aws_sqs_queue.orders.url }
output "orders_queue_arn" { value = aws_sqs_queue.orders.arn }
output "dlq_arn"         { value = aws_sqs_queue.dlq.arn }
