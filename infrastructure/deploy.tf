resource "terraform_data" "grocery_deploy" {

  depends_on = [
    aws_instance.app_server,
    aws_db_instance.app_db,
    aws_s3_bucket.avatars,
    aws_cloudwatch_log_group.grocerymate_logs,
    aws_iam_role_policy.cloudwatch_logs_policy
  ]

  triggers_replace = [
    var.jwt_secret_key
  ]

  # SHTO KËTË - Copy backend folder
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.private_key_path))
      host        = aws_instance.app_server.public_ip
      timeout     = "5m"
    }

    source      = "${path.module}/../backend"
    destination = "/home/ec2-user/backend"
  }

  # PASTAJ - Execute commands
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.private_key_path))
      host        = aws_instance.app_server.public_ip
      timeout     = "5m"
    }

    inline = [
      "echo 'Waiting for EC2 initialization...'",
      "until [ -f /opt/grocery-ready ]; do sleep 5; done",
      "echo 'EC2 is ready!'",
      "cd /home/ec2-user/backend",
      "rm -f .env",
      "echo 'Waiting for RDS...'",
      "until PGPASSWORD='${var.db_password}' pg_isready -h '${aws_db_instance.app_db.address}' -p 5432 -U '${var.db_username}' -d '${aws_db_instance.app_db.db_name}'; do sleep 5; done",
      "echo 'RDS is ready!'",
      "TABLE_COUNT=$(PGPASSWORD='${var.db_password}' psql -h '${aws_db_instance.app_db.address}' -U '${var.db_username}' -d '${aws_db_instance.app_db.db_name}' -tAc \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'\")",
      "echo \"Database tables: $TABLE_COUNT\"",
      "if [ \"$TABLE_COUNT\" -eq 0 ]; then echo 'Database is empty. Initializing database...'; PGPASSWORD='${var.db_password}' psql -h '${aws_db_instance.app_db.address}' -U '${var.db_username}' -d '${aws_db_instance.app_db.db_name}' -f /home/ec2-user/backend/app/sqlite_dump_clean.sql; else echo 'Database already contains tables. Skipping database initialization.'; fi",
      "echo 'Building Docker image...'",
      "docker build -t grocerymate .",
      "echo 'Stopping old GroceryMate container if it exists...'",
      "docker rm -f grocerymate 2>/dev/null || true",
      "echo 'Starting GroceryMate container...'",
      "docker run -d --name grocerymate --network host --restart unless-stopped --log-driver awslogs --log-opt awslogs-group=\"/aws/ec2/grocerymate\" --log-opt awslogs-region=\"eu-central-1\" --log-opt awslogs-stream=\"grocerymate-app\" -e S3_BUCKET_NAME='${aws_s3_bucket.avatars.bucket}' -e S3_REGION='eu-central-1' -e USE_S3_STORAGE='true' -e POSTGRES_USER='${var.db_username}' -e POSTGRES_PASSWORD='${var.db_password}' -e POSTGRES_DB='${aws_db_instance.app_db.db_name}' -e POSTGRES_HOST='${aws_db_instance.app_db.address}' -e POSTGRES_URI='postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.app_db.address}:5432/${aws_db_instance.app_db.db_name}' -e JWT_SECRET_KEY='${var.jwt_secret_key}' grocerymate",
      "echo 'GroceryMate deployment complete!'",
      "docker ps"
    ]
  }
}
