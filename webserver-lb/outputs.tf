# --- webserver-lb/outputs.tf ---

output "tg_arn" {
  value = aws_lb_target_group.tg.arn
}

output "webserver_lb_dns_name" {
  value = aws_lb.web_lb.dns_name
}

output "webserver_lb_zone_id" {
  value = aws_lb.web_lb.zone_id
}
output "webserver_lb_dns_arn" {
  value = aws_lb.web_lb.arn
}