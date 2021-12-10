# --- networking/outputs.tf ---

output "All_AZs_Names" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = aws_vpc.health_vpc.id
}


# ========== Subnets =============
output "health_subnets_a" {
  value = aws_subnet.health_private_subnet_a.*.id
}
output "health_subnets_b" {
  value = aws_subnet.health_private_subnet_b.*.id
}
output "public_subnets" {
  value = aws_subnet.health_public_subnet.*.id
}


# Subnet Group for RDS
output "rds_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnetgroup.*.name
}
