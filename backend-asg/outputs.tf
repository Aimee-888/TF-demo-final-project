# --- backend-asg/outputs.tf ---

output "asg" {
  value = aws_autoscaling_group.asg-backend.id
}