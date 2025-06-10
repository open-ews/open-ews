module "app" {
  source = "../modules/app"

  api_subdomain           = "api-staging"
  app_subdomain           = "app-staging"
  cdn_subdomain           = "cdn-staging"
  route53_zone            = data.terraform_remote_state.core.outputs.route53_zone
  internal_route53_zone   = data.terraform_remote_state.core.outputs.internal_route53_zone
  legacy_app_route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  legacy_app_subdomain    = "scfm-staging"

  app_identifier      = "open-ews-staging"
  app_environment     = "staging"
  cdn_certificate     = data.terraform_remote_state.core.outputs.cdn_certificate
  global_accelerator  = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  region              = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  app_image           = data.terraform_remote_state.core.outputs.app_ecr_repository.this.repository_url
  rds_cluster         = data.terraform_remote_state.core.outputs.rds_cluster
  aws_region          = var.aws_region
  uploads_bucket      = "uploads-staging.open-ews.org"
  db_name             = "open_ews_staging"
  webserver_min_tasks = 0
  webserver_max_tasks = 0
  worker_min_tasks    = 0
  worker_max_tasks    = 0
}
