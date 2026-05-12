variable "project"            { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "eks_role_arn"       { type = string }
variable "node_role_arn"      { type = string }

output "cluster_name"       { value = aws_eks_cluster.main.name }
output "cluster_endpoint"   { value = aws_eks_cluster.main.endpoint }
output "cluster_ca"         { value = aws_eks_cluster.main.certificate_authority[0].data }
output "worker_instance_ids"{ value = data.aws_instances.eks_workers.ids }
