resource "random_password" "password" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "master_user_secret" {
  name = var.secret_name

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "master_user_secret_version" {
  secret_id     = aws_secretsmanager_secret.master_user_secret.id
  secret_string = random_password.password.result
}

resource "aws_iam_policy" "secret_policy" {
  name = "${var.secret_name}-secret-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:*",
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.secret_name}-*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secret_policy_attachment" {
  for_each = { for ns in var.services : ns => ns }

  role       = "${each.value}-account-role"
  policy_arn = aws_iam_policy.secret_policy.arn

  depends_on = [
    aws_iam_policy.secret_policy
  ]
}
