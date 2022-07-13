variable "region" {
  default = "us-east-1"
}
variable "vpc_cidr_range" {
  default = "10.171.4.0/23"
}

variable "peer_account_id" {
  type = string
}

/*variable "peer_vpc_id" {
  default = "vpc-b2dc53d6"
}*/

variable "AWS_DEV_ACCESS_KEY" {
  type = string
}

variable "AWS_DEV_SECRET_KEY" {
  type = string
}

variable "s3_backend_name" {
  default = "hc-infrastructure-dev-1"
}

variable "stack_number" {
  default = ["1"]

  validation {
    condition = alltrue([
      for num in var.stack_number : can(regex("[0-7]", num))
    ])
    error_message = "Only numbers between 0 and 7 are allowed."
  }
}

variable "availability_zone_1" {
  default = "us-east-1a" #"us-east-1a"
}

variable "availability_zone_2" {
  default = "us-east-1b" #"us-east-1b"
}

variable "stack_cidr" {
  default = [
    "10.171.4.0/26",
    "10.171.4.64/26",                  # "10.171.4.64/26",
    "10.171.4.128/26",
    "10.171.4.192/26",
    "10.171.5.0/26",
    "10.171.5.64/26",
    "10.171.5.128/26",
    "10.171.5.192/26",
  ]
}

variable "public_cidr_1" {
  default = [
    "10.171.4.0/28",
    "10.171.4.64/27",                                  #"10.171.4.64/28",
    "10.171.4.128/28",
    "10.171.4.192/28",
    "10.171.5.0/28",
    "10.171.5.64/28",
    "10.171.5.128/28",
    "10.171.5.192/28",
  ]
}

variable "public_cidr_2" {
  default = [
    "10.171.4.16/28",
    "10.171.4.96/27",                                   #"10.171.4.80/28",
    "10.171.4.144/28",
    "10.171.4.208/28",
    "10.171.5.16/28",
    "10.171.5.80/28",
    "10.171.5.144/28",
    "10.171.5.208/28",
  ]
}

variable "private_cidr_1" {
  default = [
    "10.171.4.32/28",
    "10.171.4.128/27",                                                      #"10.171.4.96/28",
    "10.171.4.160/28",
    "10.171.4.224/28",
    "10.171.5.32/28",
    "10.171.5.96/28",
    "10.171.5.160/28",
    "10.171.5.224/28",
  ]
}

variable "private_cidr_2" {
  default = [
    "10.171.4.48/28",
    "10.171.4.160/27",                                                  #"10.171.4.112/28",
    "10.171.4.176/28",
    "10.171.4.240/28",
    "10.171.5.48/28",
    "10.171.5.112/28",
    "10.171.5.176/28",
    "10.171.5.240/28",
  ]
}

variable "kibana_repository_name" {
  default = "kibana"
}
variable "app_repository_name" {
  default = "app"
}
variable "GraphQL_repository_name" {
  default = "graphql"
}
variable "nginx_repository_name" {
  default = "nginx"
}
variable "GraphQL_nginx_repository_name" {
  default = "graphql-nginx"
}

variable "user_management_repository_name" {
  default = "user-management"
}

variable "ec2-ssm-iam-role-name" {
  default = "ec2-ssm"
}
variable "alb_name" {
  default = "dev-lb"
}

variable "ecs-task-role-name" {
  description = "Name of the ecs-task role name"
  default     = "kibana-ecsTaskRole-stack1"
}

variable "ecs-task-execution-role-name" {
  description = "Name of the ecs-task-execution role name"
  default     = "kibana-ecsTaskExecutionRole-stack1"
}

### Cluster name for all the service
variable "cluster_name" {
  description = "Name of the cluster"
  default     = "dev"
}

variable "ecs-instance-role-name" {
  description = "Name of the ecs-instance role name"
  default     = "ecs-instance-role-stack1"
}

// GraphQL-ECS-TaskRoles (not used)
variable "ecs-task-role-name-GraphQL" {
  description = "Name of the ecs-task role name"
  default     = "graphql-ecsTaskRole-stack1"
}
variable "ecs-task-execution-role-name-GraphQL" {
  description = "Name of the ecs-task-execution role name"
  default     = "graphql-ecsTaskExecutionRole-stack1"
}

variable "instance_type" {
  description = "Instances type for the EC2 cluster instance"
  default = "t3.medium"
}

variable "instance_ingress_ports" {
  description = "List of ingress ports to allow on ec2-ecs instance"
  type = list(number)
  default = [22,8081,8001]
}


// GraphQL SecurityGroup

variable "securitygroup_name_GraphQL" {
  type        = string
  description = "Name of the securitygroup"
  default     = "graphql-sg1"
}

### Kibana Service definition
variable "kibana_ecs_map" {
  default = {
    service_name    = "kibana"
    container_image = "467609728767.dkr.ecr.us-east-1.amazonaws.com/kibana"
    container_port  = 5601
    host_port       = 5601
    cpu             = 1024
    memory          = 2048
    container_definitions = "containers/kibana_definition.json"
    service_desired_count = 0
    enable_asg            = true
    min_capacity          = 1
    max_capacity          = 2
    requires_compatibilities = "FARGATE"
    target_container_name = "kibana"
  }
}

// GraphQL service definition
variable "graphql_ecs_map" {
  default = {
    service_name    = "graphql"
    container_image = "467609728767.dkr.ecr.us-east-1.amazonaws.com/graphql:latest"
    container_port  = 80
    host_port       = 8080
    cpu             = 512
    memory          = 1024
    container_definitions = "containers/graphql_definition.json"
    service_desired_count = 0
    enable_asg            = true
    min_capacity          = 1 
    max_capacity          = 4  
    requires_compatibilities = "EC2"    
    target_container_name = "graphql-nginx" #Container name to link load balancer
  }
}

// Public service definition
variable "public_ecs_map" {
  default = {
    service_name    = "public"
    container_image = "467609728767.dkr.ecr.us-east-1.amazonaws.com/app:latest"
    container_port  = 80
    host_port       = 8888
    cpu             = 512
    memory          = 1024
    container_definitions = "containers/public_definition.json"
    service_desired_count = 0
    enable_asg            = true
    min_capacity          = 1
    max_capacity          = 4  
    requires_compatibilities = "EC2"  
    target_container_name = "public-nginx" #Container name to link load balancer  
  }
}

// user-management service definition
variable "user_management_ecs_map" {
  default = {
    service_name    = "user-management"
    container_image = "467609728767.dkr.ecr.us-east-1.amazonaws.com/nginx:latest"
    container_port  = 8000
    host_port       = 8081
    cpu             = 512
    memory          = 1024
    container_definitions = "containers/usermanagement_definition.json"
    service_desired_count = 1
    enable_asg            = true
    min_capacity          = 1
    max_capacity          = 4  
    requires_compatibilities = "EC2"   
    target_container_name = "user-management" #Container name to link load balancer 
  }
}

variable "user_management_api_ecs_map" {
  default = {
    service_name    = "user-management-api"
    container_image = "467609728767.dkr.ecr.us-east-1.amazonaws.com/nginx:latest"
    container_port  = 8000
    host_port       = 8001
    cpu             = 512
    memory          = 1024
    container_definitions = "containers/usermanagement_api_definition.json"
    service_desired_count = 1
    enable_asg            = true
    min_capacity          = 1
    max_capacity          = 4  
    requires_compatibilities = "EC2"   
    target_container_name = "user-management-api" #Container name to link load balancer 
  }
}

variable "user_management_setup_ecs_map" {
  default = {
    service_name    = "user-management-setup"
    cpu             = 512
    memory          = 512
    container_definitions = "containers/usermanagement_setup_definition.json"
    requires_compatibilities = "EC2"    
  }
}

variable "user_management_rds_map" {
  default = {
    db_allocated_storage          = 10
    db_max_allocated_storage      = 20
    db_engine                     = "postgres"
    db_engine_version             = "14.2"
    db_instance_class             = "db.t3.micro"
    db_name                       = "usermanagement"
    db_username                   = "postgres"
    db_port                       = 5432
    db_parameter_group_name       = "default.postgres14"
    db_skip_final_snapshot        = true
    db_iam_authentication_enabled = true
    db_subnet_group_name          = "main"
    db_root_password_length       = 16
  }
}


