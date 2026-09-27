resource "random_password" "database" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-database"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier              = var.name
  engine                  = "postgres"
  instance_class          = var.database_instance_class
  allocated_storage       = 20
  storage_type            = "gp3"
  db_name                 = var.database_name
  username                = var.database_username
  password                = random_password.database.result
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.database.id]
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
  copy_tags_to_snapshot   = true
  storage_encrypted       = true
  publicly_accessible     = false
  multi_az                = false
}

resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.name}/application"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    DATABASE_URL    = "postgresql://${var.database_username}:${random_password.database.result}@${aws_db_instance.main.address}:5432/${var.database_name}"
    SECRET_KEY_BASE = random_password.app_secret.result
  })
}

resource "random_password" "app_secret" {
  length  = 64
  special = false
}
