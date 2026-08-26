resource "aws_security_group" "rds_sg" {
  name        = "rds-grocery-sg"
  description = "Allow PostgreSQL access from the GroceryMate EC2 server"

  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-grocery-sg"
  }
}
