resource "aws_cloudwatch_metric_alarm" "worker_queue_size_alarm_high" {
  alarm_name          = "${var.app_identifier}-queue-size-alarm-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1000

  metric_query {
    id = "e1"
    return_data = true
    expression = "m1 + m2 + m3"
    label = "Number of Messages"
  }

  metric_query {
    id = "m1"
    return_data = false
    label = "Number of default priority messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300 # Wait this number of seconds before triggering the alarm (smallest available)
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.default.name
      }
    }
  }

  metric_query {
    id = "m2"
    return_data = false
    label = "Number of scheduler messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300 # Wait this number of seconds before triggering the alarm (smallest available)
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.scheduler.name
      }
    }
  }

  metric_query {
    id = "m3"
    return_data = false
    label = "Number of high priority messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300 # Wait this number of seconds before triggering the alarm (smallest available)
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.high_priority.name
      }
    }
  }

  metric_query {
    id = "m4"
    return_data = false
    label = "Number of low priority messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300 # Wait this number of seconds before triggering the alarm (smallest available)
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.low_priority.name
      }
    }
  }

  alarm_actions       = [aws_appautoscaling_policy.worker_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "worker_queue_size_alarm_low" {
  alarm_name          = "${var.app_identifier}-queue-size-alarm-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 500

  metric_query {
    id = "e1"
    return_data = true
    expression = "m1 + m2 + m3"
    label = "Number of Messages"
  }

  metric_query {
    id = "m1"
    return_data = false
    label = "Number of default priority messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.default.name
      }
    }
  }

  metric_query {
    id = "m2"
    return_data = false
    label = "Number of scheduler messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.scheduler.name
      }
    }
  }

  metric_query {
    id = "m3"
    return_data = false
    label = "Number of high priority messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.high_priority.name
      }
    }
  }

  metric_query {
    id = "m4"
    return_data = false
    label = "Number of low priority messages"
    metric {
      namespace           = "AWS/SQS"
      metric_name         = "ApproximateNumberOfMessagesVisible"
      period              = 300
      stat           = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.low_priority.name
      }
    }
  }

  alarm_actions       = [aws_appautoscaling_policy.worker_down.arn]
}

resource "aws_appautoscaling_policy" "worker_up" {
  name               = "worker-scale-up"
  service_namespace  = aws_appautoscaling_target.worker_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.worker_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300 # Don't run another autoscaling event for this number of seconds
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "worker_down" {
  name               = "worker-scale-down"
  service_namespace  = aws_appautoscaling_target.worker_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.worker_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_target" "appserver_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster.name}/${aws_ecs_service.appserver.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_appserver_autoscale_max_instances
  min_capacity       = var.ecs_appserver_autoscale_min_instances
}

resource "aws_appautoscaling_target" "worker_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_worker_autoscale_max_instances
  min_capacity       = var.ecs_worker_autoscale_min_instances
}


resource "aws_appautoscaling_policy" "appserver_policy" {
  name               = "appserver-scale"
  service_namespace  = aws_appautoscaling_target.appserver_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.appserver_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.appserver_scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 75
    scale_in_cooldown = 300
    scale_out_cooldown = 60
  }
}
