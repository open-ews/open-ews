module "app" {
  source = "../modules/app"

  api_subdomain         = "api-staging"
  app_subdomain         = "app-staging"
  cdn_subdomain         = "cdn-staging"
  route53_zone          = data.terraform_remote_state.core.outputs.route53_zone
  internal_route53_zone = data.terraform_remote_state.core.outputs.internal_route53_zone

  app_identifier             = "open-ews-staging"
  ecs_service_name           = "open-ews-staging"
  task_definition_name       = "open-ews-staging"
  ecs_cluster_name           = "open-ews-staging"
  container_instances_name   = "open-ews-staging"
  log_group_name             = "open-ews-staging"
  scfm_subdomain             = "scfm-staging"
  scfm_cdn_subdomain         = "cdn-scfm-staging"
  scfm_route53_zone          = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  scfm_internal_route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org
  app_environment            = "staging"
  global_accelerator         = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  region                     = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  app_image                  = data.terraform_remote_state.core.outputs.app_ecr_repository.this.repository_url
  rds_cluster                = data.terraform_remote_state.core.outputs.rds_cluster
  aws_region                 = var.aws_region
  cdn_certificate            = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  uploads_bucket             = "uploads-staging.open-ews.org"
  db_name                    = "open_ews_staging"
  webserver_min_tasks        = 0
  webserver_max_tasks        = 0
  worker_min_tasks           = 0
  worker_max_tasks           = 0
}
