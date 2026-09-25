data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  zones = {
    a = {
      name        = data.aws_availability_zones.available.names[0]
      public_cidr = "10.42.0.0/24"
      app_cidr    = "10.42.10.0/24"
      db_cidr     = "10.42.20.0/24"
    }
    b = {
      name        = data.aws_availability_zones.available.names[1]
      public_cidr = "10.42.1.0/24"
      app_cidr    = "10.42.11.0/24"
      db_cidr     = "10.42.21.0/24"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "ccl-dev-vpc"
    Project     = "cloud-change-log"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ccl-dev-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = local.zones

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value.name
  cidr_block              = each.value.public_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "ccl-dev-public-${each.key}"
  }
}

resource "aws_subnet" "app" {
  for_each = local.zones

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value.name
  cidr_block              = each.value.app_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "ccl-dev-app-${each.key}"
  }
}

resource "aws_subnet" "db" {
  for_each = local.zones

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value.name
  cidr_block              = each.value.db_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "ccl-dev-db-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ccl-dev-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ccl-dev-app-rt"
  }
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ccl-dev-db-rt"
  }
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}