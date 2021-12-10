# --- backend-lb/main.tf ---


## Creating ELB
resource "aws_lb" "backend_lb" {
  name            = "Backend-LB"
  subnets         = var.lb_subnets
  security_groups = var.lb_sg
  idle_timeout    = 400

}
resource "aws_lb_target_group" "tg" {
  name     = "Backend-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    # ensures, that a new TG is created before old one is destroyed
    # otherwise apply is hard, because Listener has nowhere to go  
    create_before_destroy = true
  }
  # Optional
  health_check {
    healthy_threshold   = var.lb_healthy_threshold   #2 
    unhealthy_threshold = var.lb_unhealthy_threshold #2 
    timeout             = var.lb_timeout             #3
    interval            = var.lb_interval            #30 
  }

}
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = var.asg
  alb_target_group_arn   = aws_lb_target_group.tg.arn
}

resource "aws_lb_listener" "webserver_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

