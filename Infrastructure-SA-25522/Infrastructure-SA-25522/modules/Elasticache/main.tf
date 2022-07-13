resource "aws_elasticache_subnet_group" "redis_subnetgroup" {
  name       = "Redis-SubnetGroup"
  subnet_ids = var.subnets
}

resource "aws_security_group" "internal_redis" {
  name   = "SG for Redis"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "TCP"
    cidr_blocks = [var.redis_sg_cidr_range]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Repo" = var.redis_module_repo
  }
}

resource "aws_elasticache_replication_group" "app" {
  automatic_failover_enabled = true
  replication_group_id       = "dev${var.stack_number}-app"
  description                = "Redis cluster for application"
  node_type                  = "cache.t3.small"
  engine_version             = "5.0.6"
  parameter_group_name       = "default.redis5.0"
  num_cache_clusters         = 2
  port                       = 6379
  security_group_ids         = [aws_security_group.internal_redis.id]
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnetgroup.name
  tags = {
    "Repo" = var.redis_module_repo
  }
}

resource "aws_elasticache_replication_group" "worker" {
  automatic_failover_enabled = true
  replication_group_id       = "dev${var.stack_number}-worker"
  description                = "Redis cluster for worker queue"
  node_type                  = "cache.t3.small"
  engine_version             = "5.0.6"
  parameter_group_name       = "default.redis5.0"
  num_cache_clusters         = 2
  port                       = 6379
  security_group_ids         = [aws_security_group.internal_redis.id]
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnetgroup.name
  tags = {
    "Repo" = var.redis_module_repo
  }
}
