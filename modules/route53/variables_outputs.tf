variable "project"     { type = string }
variable "environment" { type = string }
variable "domain_name" { type = string }
variable "alb_dns_name"{ type = string }
variable "alb_zone_id" { type = string }

output "zone_id"    { value = aws_route53_zone.main.zone_id }
output "zone_name"  { value = aws_route53_zone.main.name }
output "api_fqdn"   { value = aws_route53_record.api.fqdn }
