variable "aws_region_code" {
  default = "ca-central-1"
}

variable "lambda-iam-role-name" {
  description = "Name of the iam-role"
  default = "canada-screenshot-queue-checker"
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
  default     = "4"
}

variable "desired_stack" {
  description = "autoscale desired servers"
  default     = "2"
}

variable "launch_template" {
  default = "lt-023ca5b80cf1e0ef0"
}

variable "subnets" {
  default = ["subnet-978901ec", "subnet-5c126435"]
}

variable "datapoints_to_alarm" {
  description = "datapoints to check and trigger alarm"
  default     = "3"
}

variable "scale_up_depth" {
  description = "The value against which the Threshold is compared and trigger a scale up"
  default     = "2000"
}

variable "scale_up_minutes" {
  description = "number of consecutive samples before triggering scale up i.e:evaluation_periods"
  default     = "3"
}

variable "scale_down_depth" {
  description = "The value against which the Threshold is compared and trigger a scale down"
  default     = "2000"
}

variable "scale_down_minutes" {
  description = "number of consecutive samples before triggering scale downi.e:evaluation_periods"
  default     = "3"
}


