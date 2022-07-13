variable "stack_number" {}

variable "subnets" {}

variable "redis_sg_cidr_range" {}

variable "vpc_id" {}

variable "redis_module_repo" {
  default = "https://github.com/VacaAPI/Infrastructure/tree/master/modules/redis"
}
