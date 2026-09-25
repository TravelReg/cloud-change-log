variable "image_tag" {
  description = "Immutable ECR image tag deployed to ECS"
  type        = string
}

variable "alert_email" {
  description = "Email address for Cloud Change Log infrastructure alerts"
  type        = string
}

variable "app_hostname" {
  description = "Public hostname for Cloud Change Log"
  type        = string
}

variable "github_oidc_subject" {
  description = "GitHub main branch identity allowed to publish CCL images"
  type        = string
}

output "github_ecr_push_role_arn" {
  value = aws_iam_role.github_ecr_push.arn
}