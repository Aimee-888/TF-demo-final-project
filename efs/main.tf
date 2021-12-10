
# --- efs/main.tf ---
resource "aws_efs_file_system" "efs_some" {
  # A unique name to ensure idempotent file system creation
  creation_token = "efs-for-backendsever"

  tags = {
    Name = "MyProduct22"
  }
}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs_some.id
  subnet_id       = var.backend_subnets[0]
  security_groups = [var.backend_sg[0]]
}
resource "aws_efs_mount_target" "mount2" {
  file_system_id  = aws_efs_file_system.efs_some.id
  subnet_id       = var.backend_subnets[1]
  security_groups = [var.backend_sg[0]]
}



# nNstalling EFS on Instance

# resource "null_resource" "configure_nfs" {
#   depends_on = [aws_efs_mount_target.mount]
#    connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     private_key = "././webserver"
#     host     = "i-0ec5ec55772e740a4"
#    }
#      connection {
#     host = element(aws_instance.cluster.*.public_ip, 0)
#   }
#   provisioner "remote-exec" {
#     inline = [   
#       "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs_some.dns_name}:/  /var/www/html",
#       "sudo mount -t efs fs-068b51f13491d1df2 efs/",
#       "aws s3 ls"

#     ]
#   }
# }
