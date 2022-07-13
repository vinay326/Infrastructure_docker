provider "aws" {
  region     = "us-east-1"
  access_key = var.AWS_DEV_ACCESS_KEY
  secret_key = var.AWS_DEV_SECRET_KEY
}

terraform {
  backend "s3" {
    bucket = "hc-infrastructure-dev-1"
    key    = "infrastructure/hc-dev.tfstate"
    region = "us-east-1"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_range

  tags = {
    Name = "main VPC"
  }
}

/*resource "aws_vpc_peering_connection" "main" {
  peer_owner_id = var.peer_account_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = aws_vpc.main.id
}*/

resource "aws_internet_gateway" "int_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IG"
  }
}

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = module.logs_bucket.bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ACCEPT"
  vpc_id               = aws_vpc.main.id
}
/*
module "s3_backend" {
  source = "../modules/s3/bucket"
  name   = var.s3_backend_name
  acl    = "private"
}*/

module "logs_bucket" {
  source = "../modules/s3/bucket"
  name   = "hostcompliance.dev.logs"
  acl    = "private"
}

module "app_certificate" {
  count       = 2
  source      = "../modules/ACM/Certificate"
  domain_name = "dev${count.index}.hostcompliancedev.com"
}

module "admin_certificate" {
  count       = 2
  source      = "../modules/ACM/Certificate"
  domain_name = "dev${count.index}-admin.hostcompliancedev.com"
}

module "dev_certificate" {
  source      = "../modules/ACM/Certificate"
  domain_name = "*.hostcompliancedev.com"
}

module "stack_network" {
  for_each            = toset(var.stack_number)
  source              = "../modules/network_stack"
  vpc_id              = aws_vpc.main.id
 # vpc_peering_id      = aws_vpc_peering_connection.main.id
  int_gw_id           = aws_internet_gateway.int_gw.id
  public_cidr_1       = var.public_cidr_1[each.value]
  public_cidr_2       = var.public_cidr_2[each.value]
  private_cidr_1      = var.private_cidr_1[each.value]
  private_cidr_2      = var.private_cidr_2[each.value]
  availability_zone_1 = var.availability_zone_1
  availability_zone_2 = var.availability_zone_2
  stack_number      = each.value
}


// Create ECR repositories
/*module "kibana_ecr_repository" {
  source          = "../modules/ECR"
  repository_name = var.kibana_repository_name
}
module "app_ecr_repository" {
  source          = "../modules/ECR"
  repository_name = var.app_repository_name
}
module "GraphQL_ecr_repository" {
  source          = "../modules/ECR"
  repository_name = var.GraphQL_repository_name
}
module "nginx_ecr_repository" {
  source          = "../modules/ECR"
  repository_name = var.nginx_repository_name
}
module "GraphQL-nginx_ecr_repository" {
  source          = "../modules/ECR"
  repository_name = var.GraphQL_nginx_repository_name
}
*/
module "user_management_ecr_repository" {
  source          = "../modules/ECR"
  repository_name = var.user_management_repository_name
}

### ECS Cluster creation and EC2

module "ecs_ec2_instance" {
  for_each                    = toset(var.stack_number)
  source = "../modules/ec2-ecs"
  vpc_id = aws_vpc.main.id
  private_subnet_ids = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  cluster_name = "${var.cluster_name}${each.value}"
  instance_ingress_ports = var.instance_ingress_ports
  instance_type = var.instance_type
}

## Kibana Service

//Create ECS Kibana Service + Task definition
module "ecs_kibana" {
  for_each                    = toset(var.stack_number)
  source                      = "../modules/ecs"
  cluster_name                = "${var.cluster_name}${each.value}"
  subnets                     = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  ecs_task_role_arn           = aws_iam_role.ecs_task_role.arn
  services_map                = var.kibana_ecs_map
  network_mode                = "awsvpc"
  public_subnets              = [module.stack_network[each.value].public_subnet_1, module.stack_network[each.value].public_subnet_2]
  alb_certificate_arn         = module.dev_certificate.arn
  vpc_id                      = aws_vpc.main.id
  health_check                = "/status"
  region                      = var.region
}

## GraphQL Service

//This block is used to create ECS service GraphQL
 module "ecs_graphql" {
  for_each                    = toset(var.stack_number)
  source                      = "../modules/ecs"
  cluster_name                = "${var.cluster_name}${each.value}"
  subnets                     = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  ecs_task_role_arn           = aws_iam_role.ecs_task_role.arn
  services_map                = var.graphql_ecs_map
  network_mode                = "bridge"
  public_subnets              = [module.stack_network[each.value].public_subnet_1, module.stack_network[each.value].public_subnet_2]
  alb_certificate_arn         = module.dev_certificate.arn
  vpc_id                      = aws_vpc.main.id
  health_check                = "/"
  region                      = var.region
}

## Public Service

//This block is used to create ECS service Public
 module "ecs_public" {
  for_each                    = toset(var.stack_number)
  source                      = "../modules/ecs"
  cluster_name                = "${var.cluster_name}${each.value}"
  subnets                     = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  public_subnets              = [module.stack_network[each.value].public_subnet_1, module.stack_network[each.value].public_subnet_2]
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  ecs_task_role_arn           = aws_iam_role.ecs_task_role.arn
  services_map                = var.public_ecs_map
  network_mode                = "bridge"
  alb_certificate_arn         = module.dev_certificate.arn
  vpc_id                      = aws_vpc.main.id
  health_check                = "/_status?internal_key=gzyGJ642XsKdMp"
  region                      = var.region
}

//This block is used to create ECS service User-Management
 module "ecs_user_management" {
  for_each                    = toset(var.stack_number)
  source                      = "../modules/ecs"
  cluster_name                = "${var.cluster_name}${each.value}"
  subnets                     = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  ecs_task_role_arn           = aws_iam_role.ecs_task_role.arn
  services_map                = var.user_management_ecs_map
  network_mode                = "bridge"
  public_subnets              = [module.stack_network[each.value].public_subnet_1, module.stack_network[each.value].public_subnet_2]
  alb_certificate_arn         = module.dev_certificate.arn
  vpc_id                      = aws_vpc.main.id
  health_check                = "/health-check/"
  region                      = var.region
}

module "ecs_user_management_api" {
  for_each                    = toset(var.stack_number)
  source                      = "../modules/ecs"
  cluster_name                = "${var.cluster_name}${each.value}"
  subnets                     = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  ecs_task_role_arn           = aws_iam_role.ecs_task_role.arn
  services_map                = var.user_management_api_ecs_map
  network_mode                = "bridge"
  public_subnets              = [module.stack_network[each.value].public_subnet_1, module.stack_network[each.value].public_subnet_2]
  alb_certificate_arn         = module.dev_certificate.arn
  vpc_id                      = aws_vpc.main.id
  health_check                = "/health-check/"
  region                      = var.region
}

module "ecs_user_management_setup" {
  for_each                    = toset(var.stack_number)
  source                      = "../modules/ecs/ecs_task_run"
  cluster_name                = "${var.cluster_name}${each.value}"
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  ecs_task_role_arn           = aws_iam_role.ecs_task_role.arn
  service_map                 = var.user_management_setup_ecs_map
  network_mode                = "bridge"
}

module "rds_user_management" {
  for_each                    = toset(var.stack_number)
  source                        = "../modules/rds"
  db_allocated_storage          = var.user_management_rds_map.db_allocated_storage
  db_max_allocated_storage      = var.user_management_rds_map.db_max_allocated_storage
  db_engine                     = var.user_management_rds_map.db_engine
  db_engine_version             = var.user_management_rds_map.db_engine_version
  db_instance_class             = var.user_management_rds_map.db_instance_class
  db_name                       = var.user_management_rds_map.db_name
  db_username                   = var.user_management_rds_map.db_username
  db_port                       = var.user_management_rds_map.db_port
  db_parameter_group_name       = var.user_management_rds_map.db_parameter_group_name
  db_skip_final_snapshot        = var.user_management_rds_map.db_skip_final_snapshot
  db_iam_authentication_enabled = var.user_management_rds_map.db_iam_authentication_enabled
  db_subnet_group_name          = var.user_management_rds_map.db_subnet_group_name
  db_subnet_group_id            = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  db_root_password_length       = var.user_management_rds_map.db_root_password_length
  db_identifier                 = "user-management-${var.cluster_name}${each.value}"
  vpc_id                        = aws_vpc.main.id
}

module "s3_user_management" {
  source = "../modules/s3/bucket"
  name   = "usermanagement.hostcompliance.dev"
  acl    = "private"
}



// Create redis service for Kibana
/*
module "redis" {
  for_each            = toset(var.stack_number)
  source              = "../modules/Elasticache"
  stack_number        = each.value
  subnets             = [module.stack_network[each.value].private_subnet_1, module.stack_network[each.value].private_subnet_2]
  redis_sg_cidr_range = var.stack_cidr[each.value]
  vpc_id              = aws_vpc.main.id
}*/

//SG for ECS Kibana Service
#module "security_groups" {
#  source             = "../modules/security-groups"
#  securitygroup_name = var.securitygroup_name
#  vpc-id             = aws_vpc.main.id
#  container_port     = var.kibana_ecs_map.container_port
#  cidr-block         = var.vpc_cidr_range
#}