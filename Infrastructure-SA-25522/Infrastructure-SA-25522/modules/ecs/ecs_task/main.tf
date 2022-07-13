### Task definition
resource "aws_ecs_task_definition" "aws-ecs-task" {
  family                   = "${var.service_name}-task"
  requires_compatibilities = [var.requires_compatibilities]  
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = var.network_mode 
  container_definitions    = templatefile(var.container_definitions, {
    ecs_cluster_name    = var.ecs_cluster,
    region              = var.region
  })
}

resource "aws_ecs_service" "main" {
  name                               = var.service_name
  cluster                            = var.ecs_cluster
  task_definition                    = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(
    aws_ecs_task_definition.aws-ecs-task.revision,
    data.aws_ecs_task_definition.ecs_tasks.revision,
  )}"
  desired_count                      = var.service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = var.requires_compatibilities
  scheduling_strategy                = "REPLICA"
 
  #This section is only for FARGATE Task (awsvpc network type)
  dynamic "network_configuration" {
    for_each = var.requires_compatibilities=="FARGATE" ? ["true"] : []
    content {
      security_groups  = var.ecs_service_security_groups
      subnets          = [var.subnets[0], var.subnets[1]]
      assign_public_ip = false
    }
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

}

resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_asg ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.ecs_cluster}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count              = var.enable_asg ? 1 : 0
  name               = "${var.service_name}-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}


