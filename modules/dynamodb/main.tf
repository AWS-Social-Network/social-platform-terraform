###############################################################
# modules/dynamodb/main.tf — table + DynamoDB Stream
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

# Posts table 
resource "aws_dynamodb_table" "posts" {
  name         = "${local.prefix}-posts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "post_id"

  stream_enabled = true
  

  attribute {
    name = "post_id"
    type = "S"
  }

  tags = { Name = "${local.prefix}-posts" }
}
