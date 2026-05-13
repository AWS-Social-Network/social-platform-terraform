###############################################################
# ROOT main.tf — orchestrates the localstack architecture
###############################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2            = var.localstack_endpoint
    ecr            = var.localstack_endpoint
    eks            = var.localstack_endpoint
    iam            = var.localstack_endpoint
    sts            = var.localstack_endpoint
    s3             = var.localstack_endpoint
    dynamodb       = var.localstack_endpoint
    lambda         = var.localstack_endpoint
    sqs            = var.localstack_endpoint
    sns            = var.localstack_endpoint
    elasticache    = var.localstack_endpoint
    rds            = var.localstack_endpoint
    route53        = var.localstack_endpoint
    elbv2          = var.localstack_endpoint
    cloudwatch     = var.localstack_endpoint
    logs           = var.localstack_endpoint
    secretsmanager = var.localstack_endpoint
    ssm            = var.localstack_endpoint
  }
}

module "iam" {
  source      = "./modules/iam"
  project     = var.project
  environment = var.environment
}

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  project     = var.project
  environment = var.environment
}

module "sqs" {
  source      = "./modules/sqs"
  project     = var.project
  environment = var.environment
}

module "rds" {
  source             = "./modules/rds"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password        = var.db_password
}

module "elasticache" {
  source             = "./modules/elasticache"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "eks" {
  source             = "./modules/eks"
  project            = var.project
  environment        = var.environment
  ghcr_pat           = var.ghcr_pat
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_role_arn       = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
}

module "k8s" {
  source             = "./modules/k8s"
  project            = var.project
  environment        = var.environment
  ghcr_pat           = var.ghcr_pat
  cluster_name       = module.eks.cluster_name
  cluster_endpoint   = module.eks.cluster_endpoint
  cluster_ca         = module.eks.cluster_ca
  cluster_auth_token = module.eks.cluster_auth_token
}

module "alb" {
  source              = "./modules/alb"
  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  target_instance_ids = module.eks.worker_instance_ids
  auth_node_port      = 30080
  post_node_port      = 30081
  feed_node_port      = 30082
}

module "route53" {
  source       = "./modules/route53"
  project      = var.project
  environment  = var.environment
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
  domain_name  = var.domain_name
}

module "ecr" {
  source      = "./modules/ecr"
  project     = var.project
  environment = var.environment
}

module "lambda" {
  source              = "./modules/lambda"
  project             = var.project
  environment         = var.environment
  lambda_role_arn     = module.iam.lambda_role_arn
  dynamodb_table_name = module.dynamodb.main_table_name
  dynamodb_stream_arn = module.dynamodb.stream_arn
  sqs_queue_url       = module.sqs.orders_queue_url
  localstack_endpoint = var.localstack_endpoint
  ecr_repository_url  = module.ecr.repository_url
}
