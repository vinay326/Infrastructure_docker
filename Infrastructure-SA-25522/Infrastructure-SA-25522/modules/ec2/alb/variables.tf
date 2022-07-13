variable "alb_name" {
}

variable "alb_security_groups" {
}

variable "alb_delete_protection_sw" {
  default = false
}

variable "certificate" {
}

variable "target_group" {
}

variable "alb_subnets" {
}

variable "app_lb_additional_rules" {
  default = {}
}
