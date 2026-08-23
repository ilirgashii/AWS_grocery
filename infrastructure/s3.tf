resource "aws_s3_bucket" "avatars" {
  bucket = "grocerymate-avatars-test-ig"


  tags = {
    Name        = "Grocerymate-Avatars"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "avatars_versioning" {
  bucket = aws_s3_bucket.avatars.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "avatars_public_access" {
  bucket = aws_s3_bucket.avatars.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}   

