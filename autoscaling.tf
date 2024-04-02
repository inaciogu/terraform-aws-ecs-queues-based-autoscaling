resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = var.service.autoscaling.max_capacity
  min_capacity       = var.service.autoscaling.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [module.ecs-service]
}

resource "aws_appautoscaling_policy" "ecs_scale_up_policy" {
  name               = "${var.service.name}-scale-up-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.service.autoscaling.scale_up_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_scale_down_policy" {
  name               = "${var.service.name}-scale-down-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.service.autoscaling.scale_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_queues_require_consumer_policy" {
  name               = "${var.service.name}-queues-require-consumer"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = var.service.autoscaling.scale_down_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound =  0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_scale_up_alarm" {
  alarm_name          = "${var.cluster_name}-${var.service.name}-scale-up-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.cluster_name}-${var.service.name}-MessagesPerTask"
  namespace           = "AWS/ECS"
  period              = var.service.autoscaling.scale_up_alarm_period
  statistic           = "Sum"
  threshold           = var.service.autoscaling.metric_target_value
  alarm_description   = "This metric monitors the number of tasks that are required to process the messages in the SQS queues"
  alarm_actions       = [aws_appautoscaling_policy.ecs_scale_up_policy.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_scale_down_alarm" {
  alarm_name          = "${var.cluster_name}-${var.service.name}-scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.cluster_name}-${var.service.name}-MessagesPerTask"
  namespace           = "AWS/ECS"
  period              = var.service.autoscaling.scale_down_alarm_period
  statistic           = "Sum"
  threshold           = var.service.autoscaling.metric_target_value
  alarm_description   = "This metric monitors the number of tasks that are required to process the messages in the SQS queues"
  alarm_actions       = [aws_appautoscaling_policy.ecs_scale_down_policy.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_queues_require_consumer_alarm" {
  alarm_name          = "${var.cluster_name}-${var.service.name}-queues-require-consumer-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.cluster_name}-${var.service.name}-QueuesRequireConsumer"
  namespace           = "AWS/ECS"
  period              = var.service.autoscaling.scale_down_alarm_period
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "This metric indicates if the monitored queues require a consumer. The value can be 0 or 1."
  alarm_actions       = [aws_appautoscaling_policy.ecs_queues_require_consumer_policy.arn]
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service.name
  }
}
