variable "vpc_id" {}

variable "int_gw_id" {}

variable "stack_number" {}

variable "public_cidr_1" {}

variable "public_cidr_2" {}

variable "private_cidr_1" {}

variable "private_cidr_2" {}

#variable "vpc_peering_id" {}

variable "availability_zone_1" {}

variable "availability_zone_2" {}

variable "default_target_group" {
  default = ""
}

variable "admin_lb_listener_additional_rules" {
  default = {}
}

variable "app_lb_listener_additional_rules" {
  default = {}
}

variable "network_stack_repo" {
  default = "https://github.com/VacaAPI/Infrastructure/tree/master/modules/network_stack"
}
