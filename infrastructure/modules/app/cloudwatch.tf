resource "aws_cloudwatch_log_group" "app" {
  name              = var.app_identifier
  retention_in_days = 7
}
