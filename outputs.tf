###############################################################
# outputs.tf — root
###############################################################

output "vpc_id"                { value = module.vpc.vpc_id }
output "alb_dns_name"          { value = module.alb.alb_dns_name }
output "eks_cluster_name"      { value = module.eks.cluster_name }
output "eks_cluster_endpoint"  { value = module.eks.cluster_endpoint }
output "rds_endpoint"          { value = module.rds.endpoint }
output "redis_endpoint"        { value = module.elasticache.redis_endpoint }
output "s3_main_bucket"        { value = module.s3.main_bucket_name }
output "dynamodb_main_table"   { value = module.dynamodb.main_table_name }
output "sqs_orders_queue_url"  { value = module.sqs.orders_queue_url }
output "sns_main_topic_arn"    { value = module.sns.main_topic_arn }
output "route53_zone_id"       { value = module.route53.zone_id }
output "lambda_processor_arn"  { value = module.lambda.processor_arn }
