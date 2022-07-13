resource "aws_eip" "nat_gateway" {
  vpc = true
  tags = {
    Repository = var.network_stack_repo
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    "Name"     = "NAT GW stack ${var.stack_number}"
    Repository = var.network_stack_repo
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.int_gw_id
  }

  /*route {
    cidr_block                = "172.31.0.0/16"
    #vpc_peering_connection_id = var.vpc_peering_id
  }*/

  tags = {
    Name       = "Public Route Table ${var.stack_number}"
    Repository = var.network_stack_repo
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  /*route {
    cidr_block                = "172.31.0.0/16"
    #vpc_peering_connection_id = var.vpc_peering_id
  }*/

  tags = {
    Name       = "Private Route table ${var.stack_number}"
    Repository = var.network_stack_repo
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_cidr_1
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_1

  tags = {
    Name       = "Public Subnet-1 Stack-${var.stack_number}"
    Repository = var.network_stack_repo
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_cidr_2
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_2

  tags = {
    Name       = "Public Subnet-2 Stack-${var.stack_number}"
    Repository = var.network_stack_repo
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_cidr_1
  availability_zone = var.availability_zone_1

  tags = {
    Name       = "Private Subnet-1 Stack-${var.stack_number}"
    Repository = var.network_stack_repo
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_cidr_2
  availability_zone = var.availability_zone_2

  tags = {
    Name       = "Private Subnet-2 Stack-${var.stack_number}"
    Repository = var.network_stack_repo
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

output "private_subnet_1" {
  value = aws_subnet.private_subnet_1.id
}
output "private_subnet_2" {
  value = aws_subnet.private_subnet_2.id
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet_1.id
}
output "public_subnet_2" {
  value = aws_subnet.public_subnet_2.id
}