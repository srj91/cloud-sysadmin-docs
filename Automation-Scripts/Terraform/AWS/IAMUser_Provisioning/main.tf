# Configure the AWS provider
provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create IAM User
resource "aws_iam_user" "my_user" {
  name = format("customer-%s", var.user_name)
}

# Create IAM Access Key
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.my_user.name
}

# Attach IAM User Policy
resource "aws_iam_user_policy_attachment" "my_user_policy_attachment" {
  user       = aws_iam_user.my_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}