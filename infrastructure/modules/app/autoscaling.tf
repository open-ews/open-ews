resource "aws_appautoscaling_policy" "worker_queue_size" {
  name               = "${var.app_identifier}-queue-size"
  service_namespace  = aws_appautoscaling_target.worker_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.worker_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metrics {
        id          = "backlogPerWorker"
        label       = "Backlog per worker instance"
        expression  = "totalMessages / IF((runningCapacity - 1) > 0, (runningCapacity - 1), 1)"
        return_data = true
      }

      metrics {
        id          = "totalMessages"
        label       = "Total number of messages"
        expression  = "lowPriorityMessages + defaultPriorityMessages + highPriorityMessages"
        return_data = false
      }

      metrics {
        id          = "runningCapacity"
        label       = "Number of running instances in ASG"
        return_data = false

        metric_stat {
          metric {
            metric_name = "GroupInServiceInstances"
            namespace   = "AWS/AutoScaling"

            dimensions {
              name  = "AutoScalingGroupName"
              value = module.container_instances.autoscaling_group.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "lowPriorityMessages"
        label       = "Number of low priority messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.low_priority.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "defaultPriorityMessages"
        label       = "Number of default priority messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.default.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "highPriorityMessages"
        label       = "Number of high priority messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.high_priority.name
            }
          }
          stat = "Sum"
        }
      }
    }

    target_value       = 300
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "webserver_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.id}/${aws_ecs_service.webserver.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.webserver_max_tasks
  min_capacity       = var.webserver_min_tasks
}

resource "aws_appautoscaling_target" "worker_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.id}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.worker_max_tasks
  min_capacity       = var.worker_min_tasks
}

resource "aws_appautoscaling_policy" "webserver_policy" {
  name               = "webserver-scale"
  service_namespace  = aws_appautoscaling_target.webserver_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.webserver_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.webserver_scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
