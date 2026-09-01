variable "db_username" {
  description = "PostgreSQL database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the EC2 private SSH key"
  type        = string
  default     = "~/.ssh/grocery-ec2-key"
}


variable "jwt_secret_key" {
  description = "Secret key used to sign JWT authentication tokens"
  type        = string
  sensitive   = true
}