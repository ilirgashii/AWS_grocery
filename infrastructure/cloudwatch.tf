resource "aws_cloudwatch_log_group" "grocerymate_logs" { # CloudWatch Log Group for GroceryMate application logs
  name = "/aws/ec2/grocerymate"                          #name = emri real në AWS: /aws/ec2/grocerymate ✅

  retention_in_days = 7 #how long to keep logs (7 days)

  tags = {                    # tags its like sticers that you can put on AWS resources to identify them later which resorce belong and what it does 
    Name = "GroceryMate-Logs" #ths is the name of the log group in AWS sticker to the tag 
  }
}


# Allows the EC2 IAM role to send application logs to CloudWatch
resource "aws_iam_role_policy" "cloudwatch_logs_policy" { 
  name = "cloudwatch-logs-policy"
  role = aws_iam_role.grocery_ec2_role.id #policy lidhet me ec2 i njejti role si s3

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream", #ec2 mund te krijoj kanal ne log group
          "logs:PutLogEvents"     #ec2 mund te shkruaj logs ne at kanal
        ]

# Restrict log access to the GroceryMate log group
        Resource = "arn:aws:logs:eu-central-1:*:log-group:/aws/ec2/grocerymate:*" #tek cili log group? aws/ec2/grocermyate...
      }
    ]
  })
}

# Output the CloudWatch Log Group name after deployment
output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group for GroceryMate"
  value       = aws_cloudwatch_log_group.grocerymate_logs.name
}


