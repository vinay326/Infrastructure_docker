variable "screenshot_queue_checker" {
  type = string
   default = "screenshot-queue-checker"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_exec_policy_doc" {
  statement {
    sid = "AmazonEC2FullAccess"
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }

  statement {
    sid = "iamPassRole"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::523093711912:role/EC2-SSM"]
  }
  statement {
    sid = "LambdaBasicExecution"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
  statement {
    sid = "CloudwatchMetricsAndEvent"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:List*",
      "cloudwatch:PutMetricData",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
      "events:*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "SsmParameterStoreReadOnly"
    actions = [
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "CloudWatchFullAccess"
    actions = [
      "autoscaling:Describe*",
      "cloudwatch:*",
      "logs:*",
      "sns:*",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name   = "${var.screenshot_queue_checker}-policy"
  policy = data.aws_iam_policy_document.lambda_exec_policy_doc.json
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.screenshot_queue_checker}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

output "screenshot_queue_ec2_iam_role" {
  value = aws_iam_role.lambda_execution_role
}

