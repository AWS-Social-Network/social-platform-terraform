# environments/localstack/terraform.tfvars
# Source this file when running locally:
#   terraform apply -var-file=environments/localstack/terraform.tfvars

project             = "yasna"
environment         = "localstack"
aws_region          = "us-east-1"
localstack_endpoint = "http://localhost.localstack.cloud:4566/"
domain_name         = "yasna.local"
db_password         = "localstack_password_123"
aws_account_id      = "000000000000"
