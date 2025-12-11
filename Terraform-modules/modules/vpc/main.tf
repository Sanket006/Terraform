# VPC 
resource "aws_vpc" "my-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.vpc_name}"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name = "${var.vpc_name}-private-subnet"
  }   
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  } 
  
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "${var.vpc_name}-nat-gw"
  } 
   
  depends_on = [ aws_internet_gateway.igw ]
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

#Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0.0/0"  
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  
  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "private_assoc" {
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}
