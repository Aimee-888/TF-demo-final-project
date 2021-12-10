# --- webserver-lb/variables.tf ---

variable "lb_subnets" {}
variable "vpc_id" {}
variable "lb_sg" {}
variable "asg" {}
variable "listener_port" {}
variable "listener_protocol" {}

variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}

