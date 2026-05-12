###############################################################
# modules/alb/main.tf — ALB with target groups on EKS node ports
###############################################################

locals {
  prefix  = "${var.project}-${var.environment}"
  targets = var.target_instance_ids
}

resource "aws_security_group" "alb" {
  name   = "${local.prefix}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.prefix}-alb-sg" }
}

resource "aws_lb" "main" {
  name               = "${local.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = { Name = "${local.prefix}-alb" }
}

resource "aws_lb_target_group" "auth" {
  name        = "${local.prefix}-tg-auth"
  port        = var.auth_node_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "${local.prefix}-tg-auth" }
}

resource "aws_lb_target_group" "post" {
  name        = "${local.prefix}-tg-post"
  port        = var.post_node_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "${local.prefix}-tg-post" }
}

resource "aws_lb_target_group" "feed" {
  name        = "${local.prefix}-tg-feed"
  port        = var.feed_node_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "${local.prefix}-tg-feed" }
}

resource "aws_lb_target_group_attachment" "auth" {
  count            = var.target_node_count
  target_group_arn = aws_lb_target_group.auth.arn
  target_id        = local.targets[count.index]
  port             = var.auth_node_port
}

resource "aws_lb_target_group_attachment" "post" {
  count            = var.target_node_count
  target_group_arn = aws_lb_target_group.post.arn
  target_id        = local.targets[count.index]
  port             = var.post_node_port
}

resource "aws_lb_target_group_attachment" "feed" {
  count            = var.target_node_count
  target_group_arn = aws_lb_target_group.feed.arn
  target_id        = local.targets[count.index]
  port             = var.feed_node_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    path_pattern {
      values = ["/auth*"]
    }
  }
}

resource "aws_lb_listener_rule" "post" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.post.arn
  }

  condition {
    path_pattern {
      values = ["/post*"]
    }
  }
}

resource "aws_lb_listener_rule" "feed" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.feed.arn
  }

  condition {
    path_pattern {
      values = ["/feed*"]
    }
  }
}
