# --- bastionhost/main.tf ---


resource "aws_instance" "bastionhost_node" {
  count         = 1
  instance_type = var.instance_type
  # ami           = data.aws_ami.webserver_ami.id
  ami = var.ami
  tags = {
    # dec is for decimal
    "Name" = "Bastionhost"
  }

  key_name               = var.key
  vpc_security_group_ids = [var.sg[0]]
  subnet_id              = var.subnet

  #   # Copies the webserver pem file to /etc/myapp.conf
  #   provisioner "file" {
  #   source      = "/Users/aimee/Desktop/Finale/Terraform/webserver"
  #   destination = "/home/webserver.pem"
  # }

  root_block_device {
    volume_size = var.vol_size # 10
  }
}
