resource "aws_ecs_cluster" "app" {
  name = "ccl-dev"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "ccl-dev"
  }
}

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/ccl-dev"
  retention_in_days = 7

  tags = {
    Name = "ccl-dev-app-logs"
  }
}