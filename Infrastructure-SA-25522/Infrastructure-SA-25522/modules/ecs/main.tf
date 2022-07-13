##LoadBalancer

#Security group for Load balancer
resource "aws_security_group" "alb_security_group" {
  name   = "${var.services_map.service_name}-alb-sg-${var.cluster_name}" #"public-alb-sg-dev1" #var.alb_security_group_name
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
# Need this egress for the Target Group to access the container port
  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#Security Group for the container toask
resource "aws_security_group" "ecs_tasks" {
  name   =  "${var.services_map.service_name}-ecs-sg-${var.cluster_name}" #"public-ecs-sg-dev1" #var.ecs_tasks_security_group_name
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.services_map.host_port 
    to_port          = var.services_map.host_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_lb" "main" {
  name                       =  "${var.services_map.service_name}-alb-${var.cluster_name}" #service-alb-cluster  
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_security_group.id]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
}

resource "aws_alb_target_group" "main" {
  name        = "${var.services_map.service_name}-tg-${var.cluster_name}" #service-tg-cluster 
  port        = var.services_map.host_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.network_mode == "awsvpc" ? "ip" : "instance"
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check
    unhealthy_threshold = "2"
  }
  depends_on = [
    aws_lb.main
  ]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.alb_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

module "ecs_services" {
  # Service configurations
  source                      = "./ecs_task"
  ecs_cluster                 = var.cluster_name
  subnets                     = var.subnets
  ecs_task_role_arn           = var.ecs_task_role_arn
  ecs_task_execution_role_arn = var.ecs_task_execution_role_arn
  ecs_service_security_groups = [aws_security_group.ecs_tasks.id]
  network_mode                = var.network_mode
  target_group_arn            = aws_alb_target_group.main.arn
  region = var.region
   
  # Container Task definition
  service_name          = var.services_map.service_name
  container_image       = var.services_map.container_image
  cpu                   = var.services_map.cpu
  memory                = var.services_map.memory
  container_port        = var.services_map.container_port
  service_desired_count = var.services_map.service_desired_count 
  enable_asg            = var.services_map.enable_asg 
  max_capacity          = var.services_map.max_capacity 
  min_capacity          = var.services_map.min_capacity 
  container_definitions = var.services_map.container_definitions 
  requires_compatibilities = var.services_map.requires_compatibilities
  container_name = var.services_map.target_container_name
}
