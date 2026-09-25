variable "allowed_client_cidr" {
  description = "Current public IPv4 address allowed to reach the dev ALB, as a /32 CIDR"
  type        = string

  validation {
    condition = (
      can(cidrhost(var.allowed_client_cidr, 0)) &&
      endswith(var.allowed_client_cidr, "/32")
    )
    error_message = "Provide one public IPv4 address as a /32 CIDR."
  }
}

resource "aws_security_group" "alb" {
  name        = "ccl-dev-alb-sg"
  description = "Traffic for the Cloud Change Log load balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ccl-dev-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "ccl-dev-app-sg"
  description = "Traffic for Cloud Change Log ECS tasks"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ccl-dev-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "ccl-dev-db-sg"
  description = "Traffic for the Cloud Change Log database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ccl-dev-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_client" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from the allowed client IP"
  cidr_ipv4         = var.allowed_client_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_from_client" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from the allowed client IP"
  cidr_ipv4         = var.allowed_client_cidr
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward requests and health checks to ECS"
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Requests and health checks from the ALB"
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  description                  = "PostgreSQL connection to RDS"
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS to AWS services through future NAT routing"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from ECS tasks"
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}