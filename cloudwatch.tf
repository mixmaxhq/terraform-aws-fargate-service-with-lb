resource "aws_cloudwatch_metric_alarm" "http_5xx_alarming" {
  alarm_name          = "${var.name}-${var.environment}-lb-5xx-errors-high"
  alarm_description   = "Count of 5xx HTTP statuses on ${var.name}-${var.environment}'s load balancer are high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  threshold           = var.high_5xx_responses_threshold
  evaluation_periods  = "5"
  datapoints_to_alarm = "4"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"

  # The HTTPCode_ELB_5XX_Count metric is a counter; when there are no 5XX errors,
  # it is not represented as a line at zero but the lack of a line. Thus, when
  # we are missing data, it implies we are not responding with 5xx errors -
  # we're healthy & the alarm is not breaching.
  treat_missing_data = "notBreaching"

  insufficient_data_actions = []
  alarm_actions             = var.alarm_sns_topic_arns
  ok_actions                = var.alarm_sns_topic_arns

  dimensions = {
    LoadBalancer = module.alb.this_lb_arn_suffix
  }
}
