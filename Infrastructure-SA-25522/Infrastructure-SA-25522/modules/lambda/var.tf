variable "lambda_name" {
  description = " Name of the lambda function"
  default     = "screenshot-queue"
}
variable "description" {
  type = string
  default = "create & terminate splash instances when screenshot-queue is high"
}

variable "role_arn" {
  type = string
 
}

variable "handler" {
  type = string
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  type = string
  default = "python3.8"
}

variable "memory" {
   default = "512"
}

variable "timeout" {
  default  = "90"
}

variable "python_version" {
  type = string
  default = "python3.8"
}
variable "repository_root_dir" {
  type = string
}

variable "requirements_file" {
  type = string
  default = "requirements.txt"

}
variable "source_scirpts_paths" {
  type = list(any)
}

