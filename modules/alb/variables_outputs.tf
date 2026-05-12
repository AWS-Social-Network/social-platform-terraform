variable "project"             { type = string }
variable "environment"         { type = string }
variable "vpc_id"              { type = string }
variable "public_subnet_ids"   { type = list(string) }
variable "target_instance_ids" { type = list(string) }
variable "target_node_count"   { 
    type = number
    default = 2
}
variable "auth_node_port"     { type = number }
variable "post_node_port"     { type = number }
variable "feed_node_port"     { type = number }

output "alb_arn"      { value = aws_lb.main.arn }
output "alb_dns_name" { value = aws_lb.main.dns_name }
output "alb_zone_id"  { value = aws_lb.main.zone_id }
