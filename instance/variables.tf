# --- instance/variables.tf ---

variable "instance_count" {}
variable "instance_type" {}
variable "webserver_sg" {}
variable "webserver_subnets" {}

variable "vol_size" {}

variable "user_data_path" {}

variable "tg_port" {}
variable "lb_target_group_arn" {}

variable "ami" {}
variable "key" {}