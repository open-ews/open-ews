module "app" {
  source = "../modules/app"

  api_subdomain         = "api"
  app_subdomain         = "app"
  cdn_subdomain         = "cdn"
  route53_zone          = data.terraform_remote_state.core.outputs.route53_zone
  internal_route53_zone = data.terraform_remote_state.core.outputs.internal_route53_zone

  app_identifier     = "open-ews"
  app_environment    = "production"
  cdn_certificate    = data.terraform_remote_state.core.outputs.cdn_certificate
  global_accelerator = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  region             = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  app_image          = data.terraform_remote_state.core.outputs.app_ecr_repository.this.repository_url
  rds_cluster        = data.terraform_remote_state.core.outputs.rds_cluster
  aws_region         = var.aws_region
  uploads_bucket     = "uploads.open-ews.org"
  db_name            = "scfm"
  worker_min_tasks   = 1
  worker_max_tasks   = 10
}
