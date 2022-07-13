variable "name" {
  description = "Name of security group - not required if create_sg is false"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of security group"
  type        = string
  default     = "Security Group managed by Terraform"
}

variable "create" {
  description = "Whether to create security group and all rules"
  type        = bool
  default     = true
}

 variable "ingress_rules" {
  description = "List of ingress rules to create by name"
  type        = list(string)
  default     = []
}

variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))

  default = {
   
  }
}
variable "cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
  
}
#########
# Egress
#########
variable "egress_rules" {
  description = "List of egress rules to create by name"
  type        = list(string)
  default     = []
}
variable "egress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all egress rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Security group with name
##########################
resource "aws_security_group" "default" {
  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id
    tags = {
    Environment = "dev"
    Repository = "https://github.com/VacaAPI/Infrastructure/tree/master/modules/securitygroups"
    Name       = var.name
  }
}

# Security group rules with "cidr_blocks" and it uses list of rules names
resource "aws_security_group_rule" "ingress_rules" {
  count = var.create ? length(var.ingress_rules) : 0
  security_group_id = aws_security_group.default.id
  type              = "ingress"

  cidr_blocks      = var.cidr_blocks
  description      = var.rules[var.ingress_rules[count.index]][3]

  from_port = var.rules[var.ingress_rules[count.index]][0]
  to_port   = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
}

# Security group rules with "cidr_blocks" and it uses list of rules names
resource "aws_security_group_rule" "egress_rules" {
  count = var.create ? length(var.egress_rules) : 0

  security_group_id = aws_security_group.default.id
  type              = "egress"

  cidr_blocks      = var.egress_cidr_blocks
  description      = var.rules[var.egress_rules[count.index]][3]

  from_port = var.rules[var.egress_rules[count.index]][0]
  to_port   = var.rules[var.egress_rules[count.index]][1]
  protocol  = var.rules[var.egress_rules[count.index]][2]
}
