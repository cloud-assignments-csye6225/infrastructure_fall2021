locals {
  enable_dns_hostnames = true

  //   subnet_az_cidr = {
  //     "us-east-1a" = "10.0.2.0/24",
  //     "us-east-1b" = "10.0.3.0/24",
  //     "us-east-1c" = "10.0.4.0/24",
  //   }
}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = local.enable_dns_hostnames
  enable_dns_support               = true
  enable_classiclink_dns_support   = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "vpc-csye26225"
  }
}

resource "aws_subnet" "subnet-a" {

  depends_on = [aws_vpc.vpc]

  cidr_block              = var.subnet_a_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-a-csye6225"
  }
}

resource "aws_subnet" "subnet-b" {

  depends_on = [aws_vpc.vpc]

  //   for_each = local.subnet_az_cidr

  cidr_block              = var.subnet_b_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-b-csye6225"
  }
}

resource "aws_subnet" "subnet-c" {

  depends_on = [aws_vpc.vpc]

  //   for_each = local.subnet_az_cidr

  cidr_block              = var.subnet_c_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone_c
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-c-csye6225"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gw-csye6225"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.igw_cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt-csye6225"
  }
}

resource "aws_route_table_association" "a" {

  subnet_id      = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {

  subnet_id      = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "c" {

  subnet_id      = aws_subnet.subnet-c.id
  route_table_id = aws_route_table.rt.id
}