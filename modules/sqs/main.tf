###############################################################
# modules/s3/main.tf
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_s3_bucket" "main" {
  bucket        = "${local.prefix}-main-bucket"
  force_destroy = true
  tags          = { Name = "${local.prefix}-main-bucket" }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Separate bucket for QuickSight data exports / Athena results
resource "aws_s3_bucket" "analytics" {
  bucket        = "${local.prefix}-analytics-bucket"
  force_destroy = true
  tags          = { Name = "${local.prefix}-analytics-bucket" }
}

# Lambda deployment artifacts bucket
resource "aws_s3_bucket" "lambda_artifacts" {
  bucket        = "${local.prefix}-lambda-artifacts"
  force_destroy = true
  tags          = { Name = "${local.prefix}-lambda-artifacts" }
}
