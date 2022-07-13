terraform {
  required_providers {
    aws = {
      version = "~> 3.42"
    }
  }
}

provider "aws" {
  region = var.aws_region_code
}

terraform {
  backend "s3" {
    bucket = "hc-infrastructure"
    key    = "canada/hc.tfstate"
    region = "us-east-1"

  }
}

locals {
  screenshot_queue_checker_source_path      = "../lambda_scripts"
  repository_root_dir                       = "${path.module}/.."
}

# create lambda IAM role
module "lambda_iam_role" {
  source                   = "../modules/iam"
  screenshot_queue_checker = var.lambda-iam-role-name
}

### Create lambda function
module "screenshot_queue_checker_lambda" {
  source               = "../modules/lambda"
  role_arn             = module.lambda_iam_role.screenshot_queue_ec2_iam_role.arn
  repository_root_dir  = local.repository_root_dir
  source_scirpts_paths = ["${local.screenshot_queue_checker_source_path}/screenshot-queue-checker/lambda_function.py"]
}

#create cloudwatch event-rule
module "screenshot_queue_checker_event_rule" {
  source              = "../modules/cloudwatch/event"
  target_arn          = module.screenshot_queue_checker_lambda.lambda.arn
  depends_on          = [module.screenshot_queue_checker_lambda]
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_screenshot_queue_checker" {
  statement_id  = "AllowScreenshotFuncExecFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.screenshot_queue_checker_lambda.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = module.screenshot_queue_checker_event_rule.event.arn
}

module "autoscaling_group" {
  source          = "../modules/ec2/autoscale_lt"
  min_stack       = var.min_stack
  max_stack       = var.max_stack
  desired_stack   = var.desired_stack
  launch_template = var.launch_template
  subnets         = var.subnets
}

module "screenshot_ASG_policy" {
  source              = "../modules/ec2/autoscale_policies/screenshot_queue_length"
  name                = var.lambda_name
  autoscale_name      = module.autoscaling_group.name
  datapoints_to_alarm = var.datapoints_to_alarm
  scale_up_depth      = var.scale_up_depth
  scale_up_minutes    = var.scale_up_minutes
  scale_down_depth    = var.scale_down_depth
  scale_down_minutes  = var.scale_down_minutes
}
