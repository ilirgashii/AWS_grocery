
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "app_server" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.grocery_ec2_profile.name
  key_name               = aws_key_pair.grocery_key.key_name

  user_data = <<-EOF
  #!/bin/bash

  # Install Docker
  amazon-linux-extras install docker -y
  systemctl start docker
  systemctl enable docker
  usermod -a -G docker ec2-user

  # Install PostgreSQL client 14+
  amazon-linux-extras enable postgresql14
  yum clean metadata
  amazon-linux-extras install postgresql14 -y

  # Signal that EC2 is ready for deployment
  touch /opt/grocery-ready
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
