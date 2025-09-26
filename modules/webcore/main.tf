# ALB

resource "aws_security_group" "alb" {
  name        = "${var.service}-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id
}

locals {
  TG_HC_INTERVAL = 5
  TG_HC_TIMEOUT  = 5
  TG_HC_HT       = 3
  TG_HC_UT       = 3
  TG_HC_MATCHER  = "200-399"
}

resource "aws_lb_target_group" "blue" {
  name     = "${var.service}-blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = local.TG_HC_INTERVAL
    timeout             = local.TG_HC_TIMEOUT
    healthy_threshold   = local.TG_HC_HT
    unhealthy_threshold = local.TG_HC_UT
    matcher             = local.TG_HC_MATCHER
  }

  tags = {
    Name = "${var.service}-blue-tg"
  }
}

resource "aws_lb_target_group" "green" {
  name     = "${var.service}-green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = local.TG_HC_INTERVAL
    timeout             = local.TG_HC_TIMEOUT
    healthy_threshold   = local.TG_HC_HT
    unhealthy_threshold = local.TG_HC_UT
    matcher             = local.TG_HC_MATCHER
  }

  tags = {
    Name = "${var.service}-green-tg"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
  // TODO: Add green target group route

  tags = {
    Name = "${var.service}-http-listener"
  }
}

resource "aws_lb" "main" {
  name               = "${var.service}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.private_subnets

  tags = {
    Name = "${var.service}-alb"
  }
}
