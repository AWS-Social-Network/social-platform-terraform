###############################################################
# modules/route53/main.tf
###############################################################

locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = { Name = "${local.prefix}-zone" }
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
