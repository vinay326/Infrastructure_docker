output "db_hostname" {
  description = "DB hostname"
  value       = aws_db_instance.db.address
  sensitive   = true
}

output "db_port" {
  description = "DB port"
  value       = aws_db_instance.db.port
  sensitive   = true
}

output "db_username" {
  description = "DB Root username"
  value       = aws_db_instance.db.username
  sensitive   = true
}

output "db_password" {
  description = "DB root password"
  value       = random_password.root-password
  sensitive   = true
}

output "db_name" {
  description = "DB name"
  value       = aws_db_instance.db.db_name
}
     