# environments/localstack/terraform.tfvars
# Source this file when running locally:
#   terraform apply -var-file=environments/localstack/terraform.tfvars

project             = "YASNA"
environment         = "localstack"
aws_region          = "us-east-1"
localstack_endpoint = "http://aws-localstack-server:4566"
domain_name         = "YASNA.local"
db_password         = "localstack_password_123"
aws_account_id      = "000000000000"
