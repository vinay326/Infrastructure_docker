module "iam_role" {
  source        = "../modules/iam/dev"
  iam-role-name = var.ec2-ssm-iam-role-name
}

data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = var.ecs-task-role-name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs-task-execution-role-name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::467609728767:policy/decrypt_parameter_store"

  ])
  policy_arn = each.value
}


// IAM role for ECS Instance

resource "aws_iam_role" "ecs_instance_role" {
  name               = var.ecs-instance-role-name
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_policy.json
  //assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

data "aws_iam_policy_document" "ecs_instance_policy" {
  statement {
    sid       = "ReadParams"
    effect    = "Allow"
    resources = ["arn:aws:ssm:us-east-1:467609728767:parameter/*"]
    actions   = ["ssm:GetParametersByPath"]
  }

  statement {
    sid       = "Decrypt"
    effect    = "Allow"
    resources = ["arn:aws:kms:us-east-1:467609728767:key/*"]
    actions   = ["kms:Decrypt"]
  }
}

# resource "aws_iam_role_policy_attachment_GraphQL" "ecs-task-execution-role-policy-attachment-GraphQL" {
#   role = aws_iam_role.ecs_instance_role.name
#   for_each = toset([
#     "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
#     "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   ])
#   policy_arn = each.value
# }

data "aws_iam_policy_document" "ecs_task_role2" {
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



### EC2 for ECS service
resource "aws_security_group" "ecs_sg" {
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = "aws_iam_role.ecs_agent.name"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-0022f774911c1d690"
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=dev1 >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [aws_subnet.pub_subnet.id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = 1
    min_size                  = 1
    max_size                  = 10
    health_check_grace_period = 300
    health_check_type         = "EC2"
}
