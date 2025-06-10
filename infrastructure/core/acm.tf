module "ssl_certificate" {
  source = "../modules/ssl_certificate"

  domain_name = "open-ews.org"
  subject_alternative_names = [
    "*.app.open-ews.org",
    "*.app-staging.open-ews.org",
    "*.open-ews.org"
  ]
  route53_zone = aws_route53_zone.this
}
