resource "aws_vpc" "grocery_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name        = "GroceryMate-VPC"
    Environment = "Dev"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.grocery_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "GroceryMate-Public-Subnet"
  }
}


resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.grocery_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "GroceryMate-Private-Subnet-1"
  }
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.grocery_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "GroceryMate-Private-Subnet-2"
  }
}

resource "aws_internet_gateway" "grocery_igw" {
  vpc_id = aws_vpc.grocery_vpc.id

  tags = {
    Name = "GroceryMate-IGW"
  }
}

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