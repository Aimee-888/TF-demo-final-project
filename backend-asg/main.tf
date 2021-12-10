# --- backend-asg/main.tf ---

data "aws_ami" "backend_ami" {
  most_recent = true
  # owners      = ["099720109477"]
  owners = ["amazon"]
  filter {
    name = "name"
    # values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20210415"]
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# ======= Launch Configuration ============
resource "aws_launch_template" "LaunchTemplateWebserver" {
  # creates a unique name beginning with the specified prefix
  name_prefix            = "backend-"
  image_id               = data.aws_ami.backend_ami.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [var.backend_sg[0]]

  iam_instance_profile {
    arn = var.s3_iam_instance_profile_arn
  }


  user_data = filebase64("./backend-userdata.sh")
}













# =========== ASG =================
resource "aws_autoscaling_group" "asg-backend" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.backend_subnets
  #target_group_arns   = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.LaunchTemplateWebserver.id
    version = "$Latest"
  }

  tags = [
    {
      key                 = "Name"
      value               = "ASG-Backend"
      propagate_at_launch = true
    }
  ]
}