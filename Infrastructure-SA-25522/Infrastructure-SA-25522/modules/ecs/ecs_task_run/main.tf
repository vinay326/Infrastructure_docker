### Task definition
resource "aws_ecs_task_definition" "aws-ecs-task" {
  family                   = "${var.service_map.service_name}-task"
  requires_compatibilities = [var.service_map.requires_compatibilities]  #On this directive we need to set the FARGATE Value
  cpu                      = var.service_map.cpu
  memory                   = var.service_map.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = var.network_mode #"bridge"#"awsvpc"
  container_definitions    = templatefile(var.service_map.container_definitions, {
    ecs_cluster_name    = "dev1",
    region              = "us-east-1"
  })
}
