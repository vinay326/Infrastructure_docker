variable "autoscale_name" {
  description = "Name"
  default = "splash-ASG"
}

variable "min_stack" {
  description = "autoscale minimum servers"
  default     = 1
}

variable "max_stack" {
  description = "autoscale maximum servers"
  default     = 20
}

variable "desired_stack" {
  description = "autoscale desired servers"
  default     = null
}

variable "subnets" {
  description = "subnets in which to launch the servers"
}

variable "launch_template" {
  description = "id of the launch template"
}

resource "aws_autoscaling_group" "default" {
  name                = var.autoscale_name
  min_size            = var.min_stack
  max_size            = var.max_stack
  desired_capacity    = var.desired_stack
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = var.launch_template
    version = "$Latest"
  }

}

output "name" {
  value = aws_autoscaling_group.default.name
}

output "arn" {
  value = aws_autoscaling_group.default.arn
}
