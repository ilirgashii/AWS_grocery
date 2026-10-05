# Main VPC for GroceryMate infrastructure
resource "aws_vpc" "grocery_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name        = "GroceryMate-VPC"
    Environment = "Dev"
  }
}

# Public subnet - hosts the EC2 application server
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.grocery_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "GroceryMate-Public-Subnet"
  }
}

# Private subnets - used by the RDS DB subnet group
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.grocery_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "GroceryMate-Private-Subnet-1"
  }
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.grocery_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "GroceryMate-Private-Subnet-2"
  }
}

# Internet Gateway - provides internet connectivity to the public subnet
resource "aws_internet_gateway" "grocery_igw" {
  vpc_id = aws_vpc.grocery_vpc.id

  tags = {
    Name = "GroceryMate-IGW"
  }
}

# Public route table - routes internet traffic through the IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.grocery_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.grocery_igw.id
  }

  tags = {
    Name = "GroceryMate-public-RT"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Private route table - no direct route to the internet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.grocery_vpc.id

  tags = {
    Name = "GroceryMate-private-RT"
  }
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}


# RDS requires subnets in at least two Availability Zones
resource "aws_db_subnet_group" "grocery_db_subnet_group" {
  name = "grocerymate-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "GroceryMate-RDS-Subnet-Group"
  }
}


