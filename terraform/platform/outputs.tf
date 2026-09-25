output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for subnet in values(aws_subnet.public) : subnet.id]
}

output "app_subnet_ids" {
  value = [for subnet in values(aws_subnet.app) : subnet.id]
}

output "db_subnet_ids" {
  value = [for subnet in values(aws_subnet.db) : subnet.id]
}

output "app_route_table_id" {
  value = aws_route_table.app.id
}

output "db_route_table_id" {
  value = aws_route_table.db.id
}
output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "ecs_target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "nat_gateway_id" {
  value = aws_nat_gateway.app.id
}
output "ecs_cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "ecs_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_app.name
}

output "admin_token_secret_arn" {
  value = aws_secretsmanager_secret.admin_token.arn
}

output "db_app_password_secret_arn" {
  value = aws_secretsmanager_secret.db_app_password.arn
}

output "db_bootstrap_task_definition_arn" {
  value = aws_ecs_task_definition.db_bootstrap.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.web.name
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.app.arn
}

output "acm_dns_validation_records" {
  value = [
    for record in aws_acm_certificate.app.domain_validation_options : {
      name  = record.resource_record_name
      type  = record.resource_record_type
      value = record.resource_record_value
    }
  ]
}