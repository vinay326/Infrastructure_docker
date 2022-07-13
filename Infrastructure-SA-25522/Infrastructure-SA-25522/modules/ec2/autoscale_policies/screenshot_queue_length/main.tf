variable "name" {
  description = "name prefix for the scaling policies"
}

variable "autoscale_name" {
  description = " Name of the auto-scaling group"
  default     = "splash-ASG"
}

variable "scale_up_depth" {
  description = "Queue depth to trigger a scale up"
  default     = "1000"
}

variable "scale_down_depth" {
  description = "queue depth to trigger a scale down"
  default     = "1000"
}

variable "scale_up_minutes" {
  description = "number of consecutive samples before triggering scale up"
  default     = "5"
}

variable "scale_down_minutes" {
  description = "number of consecutive samples before triggering scale down"
  default     = "5"
}

variable "datapoints_to_alarm" {
  description = "datapoints to trigger alarm"
  default     = 1
}


resource "aws_autoscaling_policy" "scale-up" {
  name                   = "${var.name} queue scale up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = var.autoscale_name
}

resource "aws_cloudwatch_metric_alarm" "scale-up" {
  alarm_name          = "${var.name} queue scale up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.scale_up_minutes
  metric_name         = "ScreenshotQueueLength"
  namespace           = "SCREENSHOTQUEUE"
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.scale_up_depth
  datapoints_to_alarm = var.datapoints_to_alarm
  alarm_description   = "Alarm if queue depth grows"
  alarm_actions       = [aws_autoscaling_policy.scale-up.arn]
   dimensions = {
        QUEUE_SERVICE = "QueueLength"
  }
}

resource "aws_autoscaling_policy" "scale-down" {
  name                   = "${var.name} queue scale down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = var.autoscale_name
}

resource "aws_cloudwatch_metric_alarm" "scale-down" {
  alarm_name          = "${var.name} queue scale down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.scale_down_minutes
  metric_name         = "ScreenshotQueueLength"
  namespace           = "SCREENSHOTQUEUE"
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.scale_down_depth
  alarm_description   = "Alarm if queue depth shrinks"
  datapoints_to_alarm = var.datapoints_to_alarm
  alarm_actions       = [aws_autoscaling_policy.scale-down.arn]
   dimensions = {
        QUEUE_SERVICE = "QueueLength"
  }
}
