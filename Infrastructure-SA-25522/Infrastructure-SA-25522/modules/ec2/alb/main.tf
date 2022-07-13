resource "aws_lb" "default" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.alb_security_groups
  subnets                    = var.alb_subnets
  enable_deletion_protection = var.alb_delete_protection_sw
  tags = {
    Repository = "https://github.com/VacaAPI/Infrastructure/tree/master/modules/ec2/alb"
  }
}

resource "aws_lb_listener" "default-80" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "default-443" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate

  default_action {
    type             = "forward"
    target_group_arn = var.target_group
  }
}

resource "aws_lb_listener_rule" "additional_rules" {
  for_each     = var.app_lb_additional_rules
  listener_arn = aws_lb_listener.default-443.arn

  action {
    type             = "forward"
    target_group_arn = each.value
  }

  condition {
    path_pattern {
      values = [each.key]
    }
  }
}
