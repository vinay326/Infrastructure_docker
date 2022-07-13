resource "aws_lb_target_group" "default" {
  name     = var.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # health_check {
  #   enabled             = "true"
  #   interval            = "30"
  #   path                = var.health_check_target
  #   port                = "traffic-port"
  #   protocol            = "HTTP"
  #   timeout             = "10"
  #   healthy_threshold   = "2"
  #   unhealthy_threshold = "2"
  #   matcher             = var.status_code
  # }
  tags = {
    Repository = "https://github.com/VacaAPI/Infrastructure/tree/master/modules/ec2/target_group"
  }
}

output "arn" {
  value = aws_lb_target_group.default.arn
}
