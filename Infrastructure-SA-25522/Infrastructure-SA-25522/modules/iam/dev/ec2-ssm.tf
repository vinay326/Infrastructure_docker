variable "instance-profile-name" {
   default = "ec2_profile"
}
variable "iam-role-name" {
   default = "ec2-ssm"
}
data "aws_iam_policy_document" "ec2_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
    name = var.instance-profile-name
    role = aws_iam_role.dev-resources-iam-role.name
}

resource "aws_iam_role" "dev-resources-iam-role" {
name        = var.iam-role-name
description = "The role for the developer resources EC2"
assume_role_policy = data.aws_iam_policy_document.ec2_role_policy.json
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
    role       = aws_iam_role.dev-resources-iam-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}