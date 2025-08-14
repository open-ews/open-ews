module "rds_cluster" {
  source = "../modules/rds_cluster"

  identifier = "open-ews"
  region     = local.region
}
