output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "load_balancer_url" {
  value = "http://${aws_lb.app.dns_name}"
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "secret_arn" {
  value     = aws_secretsmanager_secret.app.arn
  sensitive = true
}

output "rds_endpoint" {
  value     = aws_db_instance.main.address
  sensitive = true
}
