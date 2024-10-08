output "frontend1_public_ip" {
  value = aws_instance.frontend1.public_dns
}

output "frontend2_public_ip" {
  value = aws_instance.frontend2.public_dns
}

output "backend1_public_ip" {
  value = aws_instance.backend1.public_dns
}

output "backend2_public_ip" {
  value = aws_instance.backend2.public_dns
}

output "database_public_ip" {
  value = aws_instance.database.public_dns
}

output "databaserds_endpoint" {
  value = aws_db_instance.db_mysql.endpoint
}

