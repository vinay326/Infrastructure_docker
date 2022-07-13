data "aws_ecs_task_definition" "ecs_tasks" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}