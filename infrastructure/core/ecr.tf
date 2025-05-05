module "app_ecr_repository_old" {
  source = "../modules/ecr_repository"
  name   = "scfm"
}

module "app_ecr_repository" {
  source = "../modules/ecr_repository"
  name   = "open-ews"
}
