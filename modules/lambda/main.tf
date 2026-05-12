###############################################################
# modules/lambda/main.tf — DynamoDB stream processor using ECR image
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_lambda_function" "stream_processor" {
  function_name = "${local.prefix}-stream-processor"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${var.ecr_repository_url}:${var.image_tag}"

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SQS_QUEUE_URL  = var.sqs_queue_url
      AWS_ENDPOINT   = var.localstack_endpoint
    }
  }

  tags = { Name = "${local.prefix}-stream-processor" }
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = var.dynamodb_stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
  batch_size        = 5
  enabled           = true
}
