# --- webserver-asg/variables.tf ---

variable "key_name" {}
variable "webserver_sg" {}
variable "webserver_subnets" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
variable "target_group_arn" {}