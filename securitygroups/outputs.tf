
# --- securitygroups/outputs.tf ---


# ========= Security Groups ==========
output "db_security_group" {
  value = [aws_security_group.sg["rds"].id]
}

output "webserver_lb_security_group" {
  value = [aws_security_group.sg["webserver_lb"].id]
}

output "webserver_security_group" {
  value = [aws_security_group.sg["webserver"].id]
}

output "backendserver_security_group" {
  value = [aws_security_group.sg["backendserver"].id]
}

output "backendserver_lb_security_group" {
  value = [aws_security_group.sg["backendserver_lb"].id]
}

output "bastionhost_security_group" {
  value = [aws_security_group.sg["bastionhost"].id]
}

