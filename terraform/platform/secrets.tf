resource "aws_secretsmanager_secret" "admin_token" {
  name                    = "ccl/dev/admin-token"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret" "db_app_password" {
  name                    = "ccl/dev/db-app-password"
  recovery_window_in_days = 7
}

resource "aws_iam_role_policy" "ecs_secret_read" {
  name = "ccl-dev-read-app-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_secretsmanager_secret.admin_token.arn,
          aws_secretsmanager_secret.db_app_password.arn,
        ]
      }
    ]
  })
}