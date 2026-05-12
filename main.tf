###############################################################
# ROOT main.tf — orchestrates all modules
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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }

  # For real AWS you would point this at S3; LocalStack uses local state.
  backend "local" {
    path = "terraform.tfstate"
  }
}

###############################################################
# Provider — LocalStack endpoint override
###############################################################
provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2            = var.localstack_endpoint
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

###############################################################
# Modules
###############################################################

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
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_role_arn       = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
}

module "alb" {
  source            = "./modules/alb"
  project           = var.project
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "lambda" {
  source              = "./modules/lambda"
  project             = var.project
  environment         = var.environment
  lambda_role_arn     = module.iam.lambda_role_arn
  dynamodb_table_name = module.dynamodb.main_table_name
  dynamodb_stream_arn = module.dynamodb.stream_arn
  sqs_queue_url       = module.sqs.orders_queue_url
  sns_topic_arn       = module.sns.main_topic_arn
  s3_bucket_name      = module.s3.main_bucket_name
  rds_endpoint        = module.rds.endpoint
  redis_endpoint      = module.elasticache.redis_endpoint
}

module "route53" {
  source       = "./modules/route53"
  project      = var.project
  environment  = var.environment
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
  domain_name  = var.domain_name
}