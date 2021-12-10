# --- root/outputs.tf ---



# understanding the data "aws_availability_zones" "available" block
output "All_AZ_Names" {
  value = module.networking.All_AZs_Names
}

# output "webserver_lb_dns_name" {
#   value = module.webserver-lb.webserver_lb_dns_name
# }


# output "bastion_ip" {
#   value = module.bastionhost.bastion_private_ip
# }

# output "name" {
#   description = "These are the NS server records"
#   value = module.route53.record-ns-records
# }

# output "Zone_id" {
#   value = module.route53.Zone_id
# }

# output "efs_id" {
#   value = module.efs.efs_id
# }