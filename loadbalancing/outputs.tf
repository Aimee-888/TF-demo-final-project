# --- loadbalancing/outputs.tf ---

output "lb_endpoint" {
  value = aws_lb.webserver_lb.dns_name
}
output "lb_target_group_arn" {
  value = aws_lb_target_group.webserver-tg.arn
}