# --- backend-lb/outputs.tf ---

output "tg_arn" {
  value = aws_lb_target_group.tg.arn
}
