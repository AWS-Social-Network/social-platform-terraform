###############################################################
# modules/sqs/main.tf — single queue + dead letter queue
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_sqs_queue" "dlq" {
  name = "${local.prefix}-dlq"
  tags = { Name = "${local.prefix}-dlq" }
}

resource "aws_sqs_queue" "orders" {
  name = "${local.prefix}-messages"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = { Name = "${local.prefix}-messages" }
}
