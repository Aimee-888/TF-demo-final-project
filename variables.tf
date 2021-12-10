# --- root/variables.tf ---

variable "aws_region" {
  default = "eu-west-1"
}

variable "access_ip" {
  type = string
}


# RDS Instance Vars
variable "dbname" {
  type = string
}

variable "dbuser" {
  type      = string
  sensitive = true
}

variable "dbpassword" {
  type      = string
  sensitive = true
}


# DocumentDB Vars 

variable "docdb_master_username" {
  type      = string
  sensitive = true
}
variable "docdb_master_password" {
  type      = string
  sensitive = true
}
