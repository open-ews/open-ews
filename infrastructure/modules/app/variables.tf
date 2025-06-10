variable "app_identifier" {}
variable "app_environment" {}
variable "app_image" {}
variable "aws_region" {}
variable "uploads_bucket" {}
variable "region" {}
variable "global_accelerator" {}
variable "rds_cluster" {}
variable "api_subdomain" {}
variable "app_subdomain" {}
variable "cdn_subdomain" {}
variable "cdn_certificate" {}
variable "route53_zone" {}
variable "internal_route53_zone" {}
variable "legacy_app_route53_zone" {}
variable "legacy_app_subdomain" {}

variable "webserver_container_port" {
  default = 80
}

variable "aws_ses_region" {
  default = "us-east-1"
}

variable "app_port" {
  default = 3000
}
variable "network_mode" {
  default = "awsvpc"
}
variable "launch_type" {
  default = "FARGATE"
}

variable "db_pool" {
  default = 48
}

variable "db_username" {
  default = "somleng"
}
variable "db_name" {}

variable "webserver_max_tasks" {
  default = 4
}
variable "webserver_min_tasks" {
  default = 1
}
variable "worker_max_tasks" {
  default = 4
}
variable "worker_min_tasks" {
  default = 1
}
# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_cpu_low_threshold_per" {
  default = "30"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_cpu_high_threshold_per" {
  default = "70"
}

variable "sqs_visibility_timeout_seconds" {
  default = 1800
}
