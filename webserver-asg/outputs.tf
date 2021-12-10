output "asg" {
  value = aws_autoscaling_group.asg-webserver.id
}


output "asg_name" {
  value = aws_autoscaling_group.asg-webserver.name
}