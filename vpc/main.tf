# --- vpc/main.tf ---

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 10
}

resource "random_shuffle" "public_az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnet
}

resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "project-vpc"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.public_az.result[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "project-igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "public-rt"
  }
}


resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_igw.id
}


resource "aws_route_table_association" "public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}