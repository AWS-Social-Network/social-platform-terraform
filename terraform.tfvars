# environments/localstack/terraform.tfvars
# Source this file when running locally:
#   terraform apply -var-file=environments/localstack/terraform.tfvars

project             = "YASNA"
environment         = "localstack"
aws_region          = "us-east-1"
# Replace with the reachable host or IP for your remote LocalStack instance.
localstack_endpoint = "http://aws-localstack-server.tail78b8fb.ts.net:4566/"
domain_name         = "YASNA.local"
db_password         = "localstack_password_123"
aws_account_id      = "000000000000"