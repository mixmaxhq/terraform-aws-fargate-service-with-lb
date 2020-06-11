resource "aws_cloudwatch_metric_alarm" "http_5xx_anomaly_detection" {
  alarm_name                = "${var.name}-${var.environment}-5xx-anomaly"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "5"
  datapoints_to_alarm       = "4"
  threshold_metric_id       = "e1"
  alarm_description         = "Count of 5xx HTTP statuses on ${var.name}-${var.environment}'s load balancer are high"
  insufficient_data_actions = []
  alarm_actions             = var.alarm_sns_topic_arns
  ok_actions                = var.alarm_sns_topic_arns

  # Missing data on this metric means that there are no 5xx errors;
  # therefore, we treat missing data as a good thing.
  treat_missing_data = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "5xx Errors (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = module.alb.this_lb_arn_suffix
      }
    }
  }
}
