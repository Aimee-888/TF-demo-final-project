# --- documentDB/variables.tf ---


variable "subnet_ids" {}

variable "instance_class" {}
variable "instance_count" {}


variable "cluster_identifier" {}
variable "engine" {}
variable "master_username" {}
variable "master_password" {}
variable "backup_retention_period" {}
variable "preferred_backup_window" {}
variable "skip_final_snapshot" {}