locals {
  prefix = "${var.project}-${var.environment}"
}


resource "aws_ecr_repository" "repo" {
  name = "${local.prefix}-repo"
}
