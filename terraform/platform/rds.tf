resource "aws_db_subnet_group" "app" {
  name       = "ccl-dev-db-subnets"
  subnet_ids = [for subnet in values(aws_subnet.db) : subnet.id]

  tags = {
    Name        = "ccl-dev-db-subnets"
    Project     = "cloud-change-log"
    Environment = "dev"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "ccl-dev-postgres"
  engine         = "postgres"
  engine_version = "16.14"
  instance_class = "db.t4g.micro"

  db_name  = "ccl"
  username = "ccl_admin"
  port     = 5432

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = false

  manage_master_user_password = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = 1

  engine_lifecycle_support = "open-source-rds-extended-support-disabled"

  # Development teardown settings. Deleting this DB will delete its data.
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "ccl-dev-postgres"
    Project     = "cloud-change-log"
    Environment = "dev"
  }
}

output "db_address" {
  value = aws_db_instance.postgres.address
}

output "db_master_secret_arn" {
  value = aws_db_instance.postgres.master_user_secret[0].secret_arn
}