# --- instance/main.tf ---

resource "random_id" "webserver_node_id" {
  byte_length = 2
  count       = var.instance_count
}

resource "aws_instance" "webserver_node" {
  count         = var.instance_count
  instance_type = var.instance_type
  # ami           = data.aws_ami.webserver_ami.id
  ami = var.ami
  tags = {
    # dec is for decimal
    "Name" = "node-${random_id.webserver_node_id[count.index].dec}"
  }

  key_name               = var.key
  vpc_security_group_ids = [var.webserver_sg[0]]
  subnet_id              = var.webserver_subnets[count.index]

  user_data = templatefile(var.user_data_path,
    {
      nodename = "webserver-${random_id.webserver_node_id[count.index].dec}"
    }
  )

  root_block_device {
    volume_size = var.vol_size # 10
  }
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.webserver_node[count.index].id
  # has to be the same as Loadbalancer - Listener port - is the number you add ":80"
  port = var.tg_port
}

