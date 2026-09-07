
provider "aws" {
  region = "eu-central-1"
}


resource "aws_instance" "app_server" {
  ami                    = "ami-0f2f6d6f49dbe9fd1"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.grocery_ec2_profile.name
  key_name               = aws_key_pair.grocery_key.key_name

  user_data = <<-EOF
  #!/bin/bash
  set -e

  echo "=== GroceryMate EC2 initialization started ==="

  # Update packages
  dnf update -y

  # Install Docker
  echo "Installing Docker..."
  dnf install -y docker

  systemctl enable docker
  systemctl start docker

  # Allow ec2-user to use Docker
  usermod -a -G docker ec2-user

  # Install PostgreSQL client
  echo "Installing PostgreSQL client..."
  dnf install -y postgresql16

  # Verify installations
  echo "Docker version:"
  docker --version

  echo "PostgreSQL client version:"
  psql --version

  # Signal that EC2 is ready for Terraform deployment
  touch /opt/grocery-ready

  echo "=== GroceryMate EC2 initialization complete ==="
EOF

  tags = {
    Name = "AWS-Grocery-Server"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-server-sg"
  description = "Allow SSH and HTTP access"

  vpc_id = aws_vpc.grocery_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "GroceryMate"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-server-sg"
  }
}

resource "aws_db_instance" "app_db" {
  identifier             = "app-grocery-db"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "grocerydb"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.grocery_db_subnet_group.name
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    name = "AWS-Grocery-DB"
  }
}
