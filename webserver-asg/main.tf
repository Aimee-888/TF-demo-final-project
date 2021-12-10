
# --- webserver-asg/main.tf ---

data "aws_ami" "webserver_ami" {
  most_recent = true
  # owners      = ["099720109477"]
  # owners = ["amazon"]
  owners = ["679593333241"]
  filter {
    name = "name"
    # values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20210415"]
    # values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    values = ["bitnami-wordpress-5.8.1-20-r07-linux-debian-10-x86_64-hvm-ebs-nami-7d426cb7-9522-4dd7-a56b-55dd8cc1c8d0"]
  }
}

# ======= Launch Configuration ============

resource "aws_launch_template" "LaunchTemplateWebserver" {
  # creates a unique name beginning with the specified prefix
  name_prefix            = "webserver-"
  image_id               = data.aws_ami.webserver_ami.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [var.webserver_sg[0]]


  user_data = filebase64("webserver-userdata.sh")
}

# =========== ASG =================
resource "aws_autoscaling_group" "asg-webserver" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.webserver_subnets
  target_group_arns   = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.LaunchTemplateWebserver.id
    version = "$Latest"
  }

  tags = [
    {
      key                 = "Name"
      value               = "ASG-Webserver"
      propagate_at_launch = true
    }
  ]
}