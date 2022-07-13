variable "name" {
  type = string
  default = "screenshot_queue_checker_event_rule"
}
variable "description" {
  type = string
  default = "screenshot queue checker event rule"
}
variable "schedule_expression" {
  type = string
  default = "cron(0/1 * * * ? *)"
}
variable "target_arn" {
  type = string
}

resource "aws_cloudwatch_event_rule" "cloudwatch_event" {
  name                = var.name
  description         = var.description
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule = aws_cloudwatch_event_rule.cloudwatch_event.name
  arn  = var.target_arn
}

output "event" {
  value = aws_cloudwatch_event_rule.cloudwatch_event
}
