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
      },
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "grocery_s3_access" {
  role       = aws_iam_role.grocery_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "grocery_ec2_profile" {
  name = "grocery-ec2-profile"
  role = aws_iam_role.grocery_ec2_role.name
}

