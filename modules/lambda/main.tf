###############################################################
# modules/lambda/main.tf
# Lambdas are deployed from zip files stored in S3.
# Placeholder ZIPs are created by the CI pipeline (see workflow).
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

###############################################################
# Stream Processor — triggered by DynamoDB Stream
###############################################################
resource "aws_lambda_function" "stream_processor" {
  function_name = "${local.prefix}-stream-processor"
  role          = var.lambda_role_arn
  handler       = "handler.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  # 
  image_uri = "${var.repository_url}:latest"

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SNS_TOPIC_ARN  = var.sns_topic_arn
      SQS_QUEUE_URL  = var.sqs_queue_url
      ENVIRONMENT    = "localstack"
    }
  }

  tags = { Name = "${local.prefix}-stream-processor" }
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = var.dynamodb_stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
  batch_size        = 10
}
