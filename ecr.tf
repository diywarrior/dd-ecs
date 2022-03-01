resource "aws_ecr_repository" "repo" {
  name                 = "repo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "repo" {
  repository = aws_ecr_repository.repo.name
  policy     = data.aws_iam_policy_document.ecr.json
}