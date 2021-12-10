# --- loadbalancing/main.tf ---

# LB for Webservers
resource "aws_lb" "webserver_lb" {
  name    = "webserver-loadbalancer"
  subnets = var.lb_subnets
  # is a tuple - not sure yet why its fine for the RDS without an index (same for instance!! WHY)
  security_groups = [var.lb_sg[0]]
  idle_timeout    = 400
}

resource "aws_lb_target_group" "webserver-tg" {
  # forces a replacement, because new string will be created
  name     = "webserver-lb-tg${substr(uuid(), 0, 3)}"
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  # Extra - NOT necessary (anything below this)
  # so TG will not be changed because of name change
  lifecycle {
    ignore_changes = [name]
    # ensures, that a new TG is created before old one is destroyed
    # otherwise apply is hard, because Listener has nowhere to go  
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold   #2 
    unhealthy_threshold = var.lb_unhealthy_threshold #2 
    timeout             = var.lb_timeout             #3
    interval            = var.lb_interval            #30 
  }
}

resource "aws_lb_listener" "webserver_lb_listener" {
  load_balancer_arn = aws_lb.webserver_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  # what is supposed to happen to traffic
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-tg.arn
  }
}