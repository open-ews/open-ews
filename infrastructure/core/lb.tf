resource "aws_lb_listener_certificate" "public" {
  listener_arn    = local.region.public_load_balancer.https_listener.arn
  certificate_arn = module.ssl_certificate.this.arn
}

resource "aws_lb_listener_certificate" "internal" {
  listener_arn    = local.region.internal_load_balancer.https_listener.arn
  certificate_arn = module.ssl_certificate.this.arn
}
