module "app" {
  source = "../modules/app"

  api_subdomain         = "api"
  app_subdomain         = "app"
  cdn_subdomain         = "cdn"
  route53_zone          = data.terraform_remote_state.core.outputs.route53_zone
  internal_route53_zone = data.terraform_remote_state.core.outputs.internal_route53_zone

  app_identifier             = "scfm"
  scfm_subdomain             = "scfm"
  scfm_cdn_subdomain         = "cdn-scfm"
  scfm_route53_zone          = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  scfm_internal_route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org
  audio_subdomain            = "audio"
  app_environment            = "production"
  global_accelerator         = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  region                     = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  app_image                  = data.terraform_remote_state.core.outputs.app_ecr_repository.this.repository_url
  rds_cluster                = data.terraform_remote_state.core.outputs.rds_cluster
  aws_region                 = var.aws_region
  cdn_certificate            = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  uploads_bucket             = "uploads.somleng.org"
  audio_bucket               = "audio.somleng.org"
  audio_bucket_cname         = "audio.somleng.org"
  db_name                    = "scfm"
  worker_min_tasks           = 1
  worker_max_tasks           = 10
}
