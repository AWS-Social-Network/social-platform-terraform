###############################################################
# modules/ecr/main.tf — ECR repository for Lambda container image
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_ecr_repository" "repo" {
  name                 = "${local.prefix}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "${local.prefix}-repo"
  }
}
