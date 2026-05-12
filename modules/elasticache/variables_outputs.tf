variable "project"             { type = string }
variable "environment"         { type = string }
variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }

output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}
