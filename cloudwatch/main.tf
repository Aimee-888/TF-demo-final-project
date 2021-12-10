# --- cloudwatch/main.tf ---


resource "aws_cloudwatch_metric_alarm" "asg-networkout" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "NetworkOut"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Maximum"
  threshold                 = "50000"
  alarm_description         = "This metric monitors ec2 NetworkOut"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}


resource "aws_cloudwatch_metric_alarm" "lb-request-count" {
  alarm_name                = "LB-Request Count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "RequestCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "120"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "Request Count of Webserver-LB"
  insufficient_data_actions = []

  dimensions = {
    # equals to "app/Webserver-LB/<numbers>
    LoadBalancer = "${replace("${var.load_balancer_arn}", "/arn:.*?:loadbalancer\\/(.*)/", "$1")}"
  }
}

