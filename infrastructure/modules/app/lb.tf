resource "aws_lb_target_group" "webserver" {
  name                 = var.app_identifier
  port                 = var.webserver_container_port
  protocol             = "HTTP"
  vpc_id               = var.region.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    protocol          = "HTTP"
    path              = "/health_checks"
    healthy_threshold = 3
    interval          = 10
  }
}

resource "aws_lb_target_group" "internal_webserver" {
  name                 = "${aws_lb_target_group.webserver.name}-internal"
  port                 = aws_lb_target_group.webserver.port
  protocol             = aws_lb_target_group.webserver.protocol
  vpc_id               = aws_lb_target_group.webserver.vpc_id
  target_type          = aws_lb_target_group.webserver.target_type
  deregistration_delay = aws_lb_target_group.webserver.deregistration_delay

  health_check {
    protocol          = aws_lb_target_group.webserver.health_check[0].protocol
    path              = aws_lb_target_group.webserver.health_check[0].path
    healthy_threshold = aws_lb_target_group.webserver.health_check[0].healthy_threshold
    interval          = aws_lb_target_group.webserver.health_check[0].interval
  }
}

resource "aws_lb_listener_rule" "webserver" {
  priority = var.app_environment == "production" ? 20 : 120

  listener_arn = var.region.public_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.app.fqdn,
        "*.${aws_route53_record.app.fqdn}",
        aws_route53_record.api.fqdn
      ]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "aws_lb_listener_rule" "legacy_app_redirect" {
  priority = var.app_environment == "production" ? 21 : 121

  listener_arn = var.region.public_load_balancer.https_listener.arn

  action {
    type = "redirect"

    redirect {
      host        = aws_route53_record.app.fqdn
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [
        aws_route53_record.legacy_app.fqdn
      ]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "aws_lb_listener_rule" "webserver_internal" {
  priority = var.app_environment == "production" ? 40 : 140

  listener_arn = var.region.internal_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_webserver.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.api_internal.fqdn
      ]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}

resource "aws_lb_listener_rule" "uploads_internal" {
  priority = var.app_environment == "production" ? 45 : 145

  listener_arn = var.region.internal_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = var.region.s3_target_group.arn
  }

  condition {
    host_header {
      values = [
        aws_route53_record.uploads.fqdn
      ]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}
