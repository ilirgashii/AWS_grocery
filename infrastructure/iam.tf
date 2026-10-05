# IAM role that allows the EC2 instance to use AWS services
resource "aws_iam_role" "grocery_ec2_role" {
  name = "grocery-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Least-privilege policy: EC2 can access objects only in the GroceryMate avatars bucket
resource "aws_iam_role_policy" "grocery_s3_access" {
  name = "grocery-s3-access"
  role = aws_iam_role.grocery_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.avatars.arn}/*"
      }
    ]
  })
}

# Attach the IAM role to the EC2 instance
resource "aws_iam_instance_profile" "grocery_ec2_profile" {
  name = "grocery-ec2-profile"
  role = aws_iam_role.grocery_ec2_role.name
}
