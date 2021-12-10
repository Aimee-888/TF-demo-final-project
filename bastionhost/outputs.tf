

output "bastion_private_ip" {
  value = aws_instance.bastionhost_node[0].private_ip
}