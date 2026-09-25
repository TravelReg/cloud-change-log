Purpose: Cloud Change Log records service changes and stores them in PostgreSQL.
Request path: Cloudflare DNS → public HTTPS ALB → ECS Fargate in private app subnets → RDS in private DB subnets.
Delivery path: GitHub Actions builds and tests Docker, publishes an immutable image to ECR, then the manual release workflow applies the selected image through Terraform.
Security: /32 ALB access, security group paths, Secrets Manager injection, and separate GitHub OIDC roles for image publishing and deployment.
Operations: /health, authenticated /changes, CloudWatch logs and alarms, and the known-good-image rollback procedure.
Initial database setup: Record the one-off ECS schema task you ran today. A new RDS database needs that step before /changes works; subsequent image releases use the existing table.