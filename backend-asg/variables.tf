# --- backend-asg/variables.tf ---

variable "key_name" {}
variable "backend_sg" {}
variable "backend_subnets" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
# variable "target_group_arn" {}

variable "s3_iam_instance_profile_arn" {}


# variable "efs_id" {}