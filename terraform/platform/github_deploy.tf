resource "aws_iam_role" "github_deploy" {
  name = "ccl-dev-github-deploy"

  # The existing trust document restricts GitHub OIDC to your configured subject.
  assume_role_policy = data.aws_iam_policy_document.github_ecr_trust.json
}

resource "aws_iam_role_policy" "github_deploy_state" {
  name = "ccl-dev-terraform-state"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListStateBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.terraform_state_bucket}"
      },
      {
        Sid    = "ReadWritePlatformState"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.terraform_state_bucket}/platform/dev/terraform.tfstate"
      },
      {
        Sid    = "ManagePlatformLock"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${var.terraform_state_bucket}/platform/dev/terraform.tfstate.tflock"
      }
    ]
  })
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}