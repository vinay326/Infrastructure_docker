variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "ecs_task_execution_role_arn" {
}

variable "ecs_task_role_arn" {
}

variable "services_map" {
  description = "Service's values "
}

variable "network_mode" {
  description = "Network mode"
}

variable "alb_certificate_arn" {
  description = "ALB Certificate ARN" #From Stack creation
  
}

variable "public_subnets" {
  description = "Public subnets"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "health_check" {
  description = "Health check for Target Group"
}

variable "region" {
}