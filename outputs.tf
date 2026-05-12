###############################################################
# outputs.tf — root
###############################################################

output "vpc_id"               { value = module.vpc.vpc_id }
output "alb_dns_name"         { value = module.alb.alb_dns_name }
output "eks_cluster_name"     { value = module.eks.cluster_name }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "rds_endpoint"         { value = module.rds.endpoint }
output "redis_endpoint"       { value = module.elasticache.redis_endpoint }
output "dynamodb_main_table"  { value = module.dynamodb.main_table_name }
output "dynamodb_stream_arn"  { value = module.dynamodb.stream_arn }
output "sqs_orders_queue_url" { value = module.sqs.orders_queue_url }
output "route53_zone_id"      { value = module.route53.zone_id }
output "route53_api_fqdn"     { value = module.route53.api_fqdn }
output "ecr_repository_url"   { value = module.ecr.repository_url }
output "lambda_processor_arn" { value = module.lambda.processor_arn }
