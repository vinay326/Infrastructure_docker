variable "aws_region_code" {
  default = "us-east-1"
}

variable "lambda_name" {
  description = " Name of the lambda function"
  default     = "screenshot-queue"
}

variable "min_stack" {
  description = "autoscale min servers"
  default     = "1"
}

variable "max_stack" {
  description = "autoscale maximum servers"
  default     = "6"
}

variable "desired_stack" {
  description = "autoscale desired servers"
  default     = "2"
}

variable "launch_template" {
  default = "lt-0a9c393c1f7658cc4"
}

variable "subnets" {
  default = ["subnet-785e4221", "subnet-5395155f"]
}


variable "datapoints_to_alarm" {
  description = "datapoints to check and trigger alarm"
  default     = "3"
}

variable "scale_up_depth" {
  description = "The value against which the Threshold is compared and trigger a scale up"
  default     = "3000"
}

variable "scale_up_minutes" {
  description = "number of consecutive samples before triggering scale up i.e:evaluation_periods"
  default     = "3"
}

variable "scale_down_depth" {
  description = "The value against which the Threshold is compared and trigger a scale down"
  default     = "3000"
}

variable "scale_down_minutes" {
  description = "number of consecutive samples before triggering scale downi.e:evaluation_periods"
  default     = "3"
}


