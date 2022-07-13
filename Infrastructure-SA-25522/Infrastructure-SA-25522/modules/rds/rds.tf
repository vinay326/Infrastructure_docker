resource "aws_db_instance" "db" {
  allocated_storage                   = var.db_allocated_storage
  max_allocated_storage               = var.db_max_allocated_storage
  engine                              = var.db_engine
  engine_version                      = var.db_engine_version
  instance_class                      = var.db_instance_class
  db_name                             = var.db_name
  username                            = var.db_username
  password                            = random_password.root-password.result
  parameter_group_name                = var.db_parameter_group_name
  skip_final_snapshot                 = var.db_skip_final_snapshot
  iam_database_authentication_enabled = var.db_iam_authentication_enabled
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  identifier                          = var.db_identifier
  vpc_security_group_ids              = [aws_security_group.rds_sg.id]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_group_id
  tags       = var.db_tags
}

resource "random_password" "root-password" {
  length           = var.db_root_password_length
  special          = false
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#Security Group for RDS service
resource "aws_security_group" "rds_sg" {
  name   =  "${var.db_identifier}-sg" 
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.db_port 
    to_port          = var.db_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
