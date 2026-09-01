resource "aws_key_pair" "grocery_key" {
  key_name   = "grocery-ec2-key"
  public_key = file(pathexpand("~/.ssh/grocery-ec2-key.pub"))
}