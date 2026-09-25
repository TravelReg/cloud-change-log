resource "aws_iam_role" "ecs_bootstrap_execution" {
  name               = "ccl-dev-bootstrap-execution"
  assume_role_policy = aws_iam_role.ecs_execution.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "ecs_bootstrap_execution" {
  role       = aws_iam_role.ecs_bootstrap_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_bootstrap_secrets" {
  name = "ccl-dev-read-bootstrap-secrets"
  role = aws_iam_role.ecs_bootstrap_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_db_instance.postgres.master_user_secret[0].secret_arn,
          aws_secretsmanager_secret.db_app_password.arn,
        ]
      }
    ]
  })
}

resource "aws_ecs_task_definition" "db_bootstrap" {
  family                   = "ccl-dev-db-bootstrap"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_bootstrap_execution.arn

  container_definitions = jsonencode([
    {
      name      = "bootstrap"
      image     = "${aws_ecr_repository.app.repository_url}:${var.bootstrap_image_tag}"
      essential = true
      command   = ["python", "-m", "app.bootstrap_db"]

      environment = [
        { name = "DB_HOST", value = aws_db_instance.postgres.address },
        { name = "DB_NAME", value = aws_db_instance.postgres.db_name },
        { name = "MASTER_DB_USER", value = aws_db_instance.postgres.username },
      ]

      secrets = [
        {
          name      = "MASTER_DB_PASSWORD"
          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_secretsmanager_secret.db_app_password.arn
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_app.name
          "awslogs-region"        = "eu-north-1"
          "awslogs-stream-prefix" = "bootstrap"
        }
      }
    }
  ])
}