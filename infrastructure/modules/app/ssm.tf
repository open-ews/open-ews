resource "aws_ssm_parameter" "rails_master_key" {
  name  = "${var.app_identifier}.${var.app_environment}.rails_master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}
