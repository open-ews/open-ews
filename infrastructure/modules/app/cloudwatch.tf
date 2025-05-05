resource "aws_cloudwatch_log_group" "app" {
  name              = var.log_group_name
  retention_in_days = 7
}
