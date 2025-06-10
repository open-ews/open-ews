output "app_ecr_repository" {
  value = module.app_ecr_repository
}

output "route53_zone" {
  value = aws_route53_zone.this
}

output "internal_route53_zone" {
  value = aws_route53_zone.this_internal
}

output "rds_cluster" {
  value     = module.rds_cluster
  sensitive = true
}

output "cdn_certificate" {
  value     = module.cdn_certificate.this
  sensitive = true
}
