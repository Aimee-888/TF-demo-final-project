# --- loadbalancing/variables.tf ---


variable "lb_subnets" {}
variable "lb_sg" {}

variable "port" {}
variable "protocol" {}
variable "vpc_id" {}

# Zusatz 
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}


variable "listener_port" {}
variable "listener_protocol" {}
