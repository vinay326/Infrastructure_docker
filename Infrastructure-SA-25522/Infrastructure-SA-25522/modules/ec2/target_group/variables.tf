variable "name" {
  description = "Name of the load balancer"
}

variable "vpc_id" {
  description = "ID of the VPC we're using"
}

variable "health_check_target" {
  description = "target for the health check"
  default     = ""
}
