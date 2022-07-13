variable "securitygroup_name" {
  type        = string
  description = "Name of the securitygroup"
}
variable "vpc-id" {
  type        = string
  description = "vpc id"
}
variable "cidr-block" {
  type        = string
  description = "CIDR block "
}
variable "container_port" {
  description = "Port of container"
}
resource "aws_security_group" "ecs_tasks" {
  name   = var.securitygroup_name
  vpc_id = var.vpc-id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port
    to_port          = var.container_port
    cidr_blocks      =  [var.cidr-block]
  }
  ingress {
    protocol        = "tcp"
    from_port       = "443"
    to_port         = "443"
    cidr_blocks      = [var.cidr-block]
  }
  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    cidr_blocks      = [var.cidr-block]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = var.securitygroup_name
  }
}
output "id" {
  value = aws_security_group.ecs_tasks.id
}