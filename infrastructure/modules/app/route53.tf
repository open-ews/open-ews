resource "aws_route53_record" "app" {
  zone_id = var.route53_zone.zone_id
  name    = var.app_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api" {
  zone_id = var.route53_zone.zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_internal" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.region.internal_load_balancer.this.dns_name
    zone_id                = var.region.internal_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "scfm_app" {
  zone_id = var.somleng_route53_zone.zone_id
  name    = "scfm"
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "uploads" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.uploads_bucket
  type    = "A"

  alias {
    name                   = var.region.internal_load_balancer.this.dns_name
    zone_id                = var.region.internal_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}
