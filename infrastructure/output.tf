output "ec2_public_ip" {
  description = "Public IP of the GroceryMate EC2 server"
  value       = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.app_db.endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket for GroceryMate avatars"
  value       = aws_s3_bucket.avatars.bucket
}
