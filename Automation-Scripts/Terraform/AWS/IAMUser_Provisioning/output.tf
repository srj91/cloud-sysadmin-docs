# Output
output "original_user_name" {
  value     = var.user_name
  sensitive = true
}

output "formatted_user_name" {
  value     = aws_iam_user.my_user.name
  sensitive = true
}

output "access_key" {
  value     = aws_iam_access_key.access_key.id
  sensitive = true
}

output "secret_key" {
  value     = aws_iam_access_key.access_key.secret
  sensitive = true
}