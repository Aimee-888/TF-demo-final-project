# --- compute/main.tf ---


# =========  AMI =========
# currently using AWS Linux2 AMI
data "aws_ami" "webserver_ami" {
  most_recent = true
  # owners      = ["099720109477"]
  owners = ["amazon"]
  filter {
    name = "name"
    # values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20210415"]
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}


# ======== SHH Key =========
resource "aws_key_pair" "webserver_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}


