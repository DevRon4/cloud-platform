resource "aws_secretsmanager_secret" "app_secret" {
  name                    = "${var.project_name}/app-config"
  description             = "Application configuration secrets"
  recovery_window_in_days = 0

  tags = { Name = "${var.project_name}-secret" }
}

resource "aws_secretsmanager_secret_version" "app_secret" {
  secret_id = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    APP_ENV     = "production"
    APP_VERSION = "2.0.0"
  })
}