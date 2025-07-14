# vpc
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = merge(var.tags,
  local.common_tags,
  {
    Name = "${var.project}-${var.environment}"
  }
  )
}

# igw
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.igw_tags,
  local.common_tags,
  {
    Name = "${var.project}-${var.environment}-igw"
  }
  )
}

# public subnet in us-east-1a, us-east-1b
# roboshop-dev-public-us-east-1a
# roboshop-dev-public-us-east-1b

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  # assign public ip while launching the instance
  map_public_ip_on_launch = true
  tags = merge(var.public_subnet_tags,
  local.common_tags,
  {
    Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
  }
  )
}

# two private subnet in us-east-1a, us-east-1b
# roboshop-dev-private-us-east-1a
# roboshop-dev-private-us-east-1b

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  #map_public_ip_on_launch = true
  tags = merge(var.private_subnet_tags,
  local.common_tags,
  {
    Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
  }
  )
}

# two database subnet in us-east-1a, us-east-1b
# roboshop-dev-database-us-east-1a
# roboshop-dev-database-us-east-1b
resource "aws_subnet" "database_subnet" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  #map_public_ip_on_launch = true
  tags = merge(var.database_subnet_tags,
  local.common_tags,
  {
    Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
  }
  )
}

# elastic-ip address
# aws_eip: provides Elastic IP resource
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-eip"
    }
  )
}

# network address translation
# aws_nat_gateway: provides a resource to create NAT gateway for vpc
# NAT allows outgoing traffic and reside in public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = merge(var.nat_tags,
  local.common_tags,
    {
      Name = "${var.project}-${var.environment}-nat"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# create aws_route_table for public subnet
# create aws_route for destination and target
# associate route_table with subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.public_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# 1. create route_table, route and associate route_table with private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private"
    }
  )
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

# create route_table, routes, associate it with subnet
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-database"
    }
  )
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database.id
}