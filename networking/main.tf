# --- networking/main.tf ---

# ========== VPC ============= 
resource "aws_vpc" "health_vpc" {
  cidr_block = var.vpc_cidr
  # can access instead of ip_adress 
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "Health-Cloud"
  }
  # helps with the igw when we change the cidr-range, no error 
  lifecycle {
    create_before_destroy = true
  }
}

# =========== IGW ==========
resource "aws_internet_gateway" "health_internet_gateway" {
  vpc_id = aws_vpc.health_vpc.id

  tags = {
    "Name" = "health_igw"
  }
}


# ====== Subnets =========

##  allows access to the list of AWS Availability Zones 
data "aws_availability_zones" "available" {

  filter {
    name   = "zone-name"
    values = ["${var.region}a", "${var.region}b"]
  }
}


# =========== Public Side ================

# RT for Public Subents
resource "aws_route_table" "health_public_rt" {
  vpc_id = aws_vpc.health_vpc.id
  # route = [{}] - not used, because required vars are long, use aws_route instead to add routes

  tags = {
    "Name" = "health_public_RT"
  }
}

# Default Route for public RT 
resource "aws_route" "default-route" {
  route_table_id         = aws_route_table.health_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.health_internet_gateway.id
}


# Public Subnet 
resource "aws_subnet" "health_public_subnet" {
  count      = var.public_subnet_count
  vpc_id     = aws_vpc.health_vpc.id
  cidr_block = var.public_cidrs[count.index]
  # to make it public 
  map_public_ip_on_launch = true
  # uses available AZ alternating (abwechselnd)
  availability_zone = (count.index % 2 == 0 ?
    data.aws_availability_zones.available.names[0] :
  data.aws_availability_zones.available.names[1])

  tags = {
    Name = "health_public_${count.index + 1}"
  }
}

resource "aws_route_table_association" "health_public_assoc" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.health_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.health_public_rt.id
}


# ====== Private Side ========

# === RTs ===

# RT for private Subnets (Main) Default - Gets automatically created, with this it can be configured
resource "aws_default_route_table" "health_private_rt_default" {
  default_route_table_id = aws_vpc.health_vpc.default_route_table_id

  tags = {
    "Name" = "health_main_RT"
  }
}

# RT & Assoc private Subnets AZ-A 
resource "aws_route_table" "health_private_rt_a" {
  vpc_id = aws_vpc.health_vpc.id

  tags = {
    "Name" = "health_private_RT-A"
  }
}
resource "aws_route" "public-route-to-nat-a" {
  route_table_id         = aws_route_table.health_private_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_public_subnet1.id
}

resource "aws_route_table_association" "health_privat_assocA" {
  count     = var.private_subnet_count_a
  subnet_id = aws_subnet.health_private_subnet_a.*.id[count.index]
  # subnet_id = ""
  route_table_id = aws_route_table.health_private_rt_a.id
}


# RT & Assoc private Subnets AZ-B
resource "aws_route_table" "health_private_rt_b" {
  vpc_id = aws_vpc.health_vpc.id

  tags = {
    "Name" = "health_private_RT-B"
  }
}

resource "aws_route" "public-route-to-nat-b" {
  route_table_id         = aws_route_table.health_private_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_public_subnet2.id
}

resource "aws_route_table_association" "health_privat_assocB" {
  count          = var.private_subnet_count_b
  subnet_id      = aws_subnet.health_private_subnet_b.*.id[count.index]
  route_table_id = aws_route_table.health_private_rt_b.id
}



# ========== Subnets =============

# AZ A
resource "aws_subnet" "health_private_subnet_a" {
  count      = var.private_subnet_count_a
  vpc_id     = aws_vpc.health_vpc.id
  cidr_block = var.private_cidrs_a[count.index]
  # using AZA und AZB abwechselnd 
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "health_private_a${count.index + 1}"
  }
}

# AZ B
resource "aws_subnet" "health_private_subnet_b" {
  count      = var.private_subnet_count_b
  vpc_id     = aws_vpc.health_vpc.id
  cidr_block = var.private_cidrs_b[count.index]
  # using AZA und AZB abwechselnd 
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "health_private_b${count.index + 1}"
  }
}


# ========= NAT =========

# Elastic IP for NAT1
resource "aws_eip" "nat_eip1" {

  vpc        = true
  depends_on = [aws_internet_gateway.health_internet_gateway]
}
# NAT1
resource "aws_nat_gateway" "nat_public_subnet1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = element(aws_subnet.health_public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.health_internet_gateway]
  tags = {
    Name = "nat1"
  }
}

# Elastic IP for NAT2
resource "aws_eip" "nat_eip2" {
  vpc        = true
  depends_on = [aws_internet_gateway.health_internet_gateway]
}
# NAT2 
resource "aws_nat_gateway" "nat_public_subnet2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = element(aws_subnet.health_public_subnet.*.id, 1)
  depends_on    = [aws_internet_gateway.health_internet_gateway]
  tags = {
    Name = "nat2"
  }
}



# RDS Subnet Group (for placement)
resource "aws_db_subnet_group" "rds_subnetgroup" {
  # name       = "aimee_rds_subnetgroup"
  # needs at least 2 AZs
  subnet_ids = [aws_subnet.health_private_subnet_a.*.id[0], aws_subnet.health_private_subnet_b.*.id[0]]

  tags = {
    Name = "aimee_rds_subnetgroup"
  }
}