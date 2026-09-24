resource "aws_ecr_repository" "app" {
  name                 = "ccl-dev"
  image_tag_mutability = "IMMUTABLE"

  tags = {
    Project     = "cloud-change-log"
    Environment = "dev"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}