variable "service_name" {
  type        = string
  description = "the name of your stack, e.g. \"demo\""
}

variable "cpu" {
  description = "The number of cpu units used by the task"
}

variable "memory" {
  description = "The amount (in MiB) of memory used by the task"
}

variable "network_mode" {
  description = "Network mode"
}

variable "container_port" {
  description = "Port of container"
}

variable "service_desired_count" {
  description = "Number of tasks running in parallel"
  default     = 2
}

variable "ecs_service_security_groups" {
  description = "Comma separated list of security groups"
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "enable_asg" {
  description = "wheather to create autoscaling policy or not"
  default     = "false"
}

variable "max_capacity" {
  description = "Maximum capacity for auto scaling application "
  default     = "10"
}

variable "min_capacity" {
  description = "Manimum capacity for auto scaling application "
  default     = "1"
}

variable "ecs_task_execution_role_arn" {
}

variable "ecs_task_role_arn" {
}

variable "ecs_cluster" {
}

variable "container_definitions" {
}
variable "requires_compatibilities" {
}

variable "target_group_arn" {
  description = "Target Group arn"
}

variable "container_name" {
  description = "container name for target group"
}

variable "region" {
}