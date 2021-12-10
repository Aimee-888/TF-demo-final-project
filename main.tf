# --- root/main.tf ---


# ====== In Prod: Don't comment Route53 out, propagation may be disturbed ======
# ====== In Dev: Don't use Route 53, or check that you hava a domain name registered and inserted in TF" 
# module "route53" {
#   source = "./route53"

#   hosted_zone_name = "aimees-tameshi.com"
#   # provide names of ns-servers of domain
#   # domain_ns_records = ["ns-1199.awsdns-21.org",
#   #   "ns-1814.awsdns-34.co.uk",
#   #   "ns-698.awsdns-23.net",
#   # "ns-470.awsdns-58.com"]

#   # For records
#   lb_dns_name = module.webserver-lb.webserver_lb_dns_name
#   lb_zone_id  = module.webserver-lb.webserver_lb_zone_id
# }



module "networking" {
  source                 = "./networking"
  vpc_cidr               = local.vpc_cidr
  public_subnet_count    = 2
  private_subnet_count_a = 3
  private_subnet_count_b = 3
  max_subnets            = 20
  region                 = local.region
  # public_cidrs = we want 10 with /24 (254 hosts) cidrsubent(prefix, newbits(32-*), netnum)
  # "10.11.0.0/24","10.11.1.0/24", "10.11.2.0/24","10.11.3.0/24",...."10.11.11.0/24"
  public_cidrs = [for i in range(0, 12, 1) : cidrsubnet(local.vpc_cidr, 8, i)]
  # private_cidrs = we want 50 starting at 10.11.12.0 with subnetmask /22 (1.022 hosts)
  # "10.11.12.0/22", "10.11.16.0/22", "10.11.20.0/22", ...
  private_cidrs_a = [for i in range(3, 20, 1) : cidrsubnet(local.vpc_cidr, 6, i)]
  # "10.11.80.0/22", 
  private_cidrs_b = [for i in range(20, 30, 1) : cidrsubnet(local.vpc_cidr, 6, i)]

}


module "securitygroups" {
  source = "./securitygroups"

  access_ip       = "0.0.0.0/0"
  vpc_id          = module.networking.vpc_id
  security_groups = local.security_groups
}


# module "rds" {
#   source            = "./rds"
#   db_storage        = 10
#   db_engine_version = "5.7.22"
#   db_instance_class = "db.t2.micro"
#   dbname            = var.dbname
#   dbuser            = var.dbuser
#   dbpassword        = var.dbpassword
#   region            = local.region
#   # like "name" in Console
#   db_identifier    = "my-sql-db"
#   skip_db_snapshot = true
#   # has only 1 value, but has to be indexed anyway because its a tuple
#   db_subnet_group_name   = module.networking.rds_subnet_group_name[0] # in outputs
#   vpc_security_group_ids = module.securitygroups.db_security_group        # in outputs
# }



# AMI & SSH Key
# Run this in terminal to create SSH-Key
# ssh-keygen -t rsa 
# ./webserver

module "compute" {
  source = "./compute"
  # For the SSH Keys
  key_name = "webserver"
  # kein guter Speicherort, aber lies sich nicht anders machen
  public_key_path = "./webserver.pub"
}


module "iam" {
  source = "./iam"
}



# module "instance" {
#   source = "./instance"
#   instance_count      = 2
#   instance_type       = "t2.micro"
#   ami                 = module.compute.ami
#   key                 = module.compute.key
#   webserver_sg        = module.securitygroups.webserver_security_group # in outputs
#   webserver_subnets   = [module.networking.health_subnets_a[2], module.networking.health_subnets_b[2]]
#   user_data_path      = "${path.root}/userdata.tpl"
#   vol_size            = 10
#   # LB Target Group Attachment
#   lb_target_group_arn = module.loadbalancing.lb_target_group_arn
#   tg_port             = 80
# }

# loadbalancing für die EC2 insatnce in instance folder
# module "loadbalancing" {
#   source     = "./loadbalancing"
#   lb_subnets = [module.networking.public_subnets[0], module.networking.public_subnets[1]]
#   lb_sg      = module.securitygroups.webserver_lb_security_group # in outputs
#   port       = 80
#   protocol   = "HTTP"
#   vpc_id     = module.networking.vpc_id
#   listener_port     = 80
#   listener_protocol = "HTTP"
#   # Zusatz - Health Check
#   lb_healthy_threshold   = 2
#   lb_unhealthy_threshold = 2
#   lb_timeout             = 3
#   lb_interval            = 30
# }

# module "webserver-asg" {
#   source = "./webserver-asg"
#   # Launch Configuration
#   key_name          = "webserver"
#   webserver_sg      = module.securitygroups.webserver_security_group # in outputs
#   webserver_subnets = [module.networking.health_subnets_a[0], module.networking.health_subnets_b[0]]
#   # Autoscaling Group
#   desired_capacity = 2
#   max_size         = 2
#   min_size         = 2
#   # IN ASG zum LB attachment 
#   target_group_arn = module.webserver-lb.tg_arn
# }

# module "webserver-lb" {
#   source            = "./webserver-lb"
#   asg               = module.webserver-asg.asg
#   lb_subnets        = [module.networking.public_subnets[0], module.networking.public_subnets[1]]
#   vpc_id            = module.networking.vpc_id
#   lb_sg             = module.securitygroups.webserver_lb_security_group # in outputs
#   listener_port     = 80
#   listener_protocol = "HTTP"

#   # Zusatz - Health Check
#   lb_healthy_threshold   = 2
#   lb_unhealthy_threshold = 2
#   lb_timeout             = 3
#   lb_interval            = 30
# }

module "backend-asg" {
  source = "./backend-asg"
  # Launch Configuration
  key_name   = "webserver"
  backend_sg = module.securitygroups.backendserver_security_group # in outputs
  backend_subnets = [module.networking.health_subnets_a[1], module.networking.health_subnets_b[1]]
  # Autoscaling Group
  desired_capacity = 2
  max_size         = 2
  min_size         = 2
  # IN ASG zum LB attachment (only activate if lb is runnig)
  # target_group_arn = module.backend-lb.tg_arn
  s3_iam_instance_profile_arn = module.iam.s3iam_instance_profile

  # efs_id = module.efs.efs_id
}

# module "backend-lb" {
#   source            = "./backend-lb"
#   asg               = module.backend-asg.asg
#   lb_subnets        = [module.networking.health_subnets_a[1], module.networking.health_subnets_b[1]]
#   vpc_id            = module.networking.vpc_id
#   lb_sg             = module.securitygroups.backendserver_lb_security_group # in outputs
#   listener_port     = 80
#   listener_protocol = "HTTP"

#   # Zusatz - Health Check
#   lb_healthy_threshold   = 2
#   lb_unhealthy_threshold = 2
#   lb_timeout             = 3
#   lb_interval            = 30
# }


# module "s3bucket" {
#   source = "./s3bucket"
# }


# takes like over 5 min to create 
module "documentdb" {
  source     = "./documentdb"
  subnet_ids = [module.networking.health_subnets_a[2], module.networking.health_subnets_b[2]]

  # Cluster Settings
  cluster_identifier      = "filecluster"
  engine                  = "docdb"
  master_username         = var.docdb_master_username
  master_password         = var.docdb_master_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true

  # Cluster Instance Settings 
  instance_count = 2
  instance_class = "db.t3.medium"
  vpc_id          = module.networking.vpc_id
  backend_sg = module.securitygroups.backendserver_security_group 
}



# module "bastionhost" {
#   source        = "./bastionhost"
#   instance_type = "t2.micro"
#   ami           = module.compute.ami
#   key           = module.compute.key
#   sg            = module.securitygroups.bastionhost_security_group # in outputs
#   subnet        = module.networking.public_subnets[0]
#   vol_size      = 8
# }


# module "config" {
#   source             = "./config"
#   config_logs_bucket = "config-bucket-for-my-test-project-223423423"
# }


# module "cloudtrail" {
#   source = "./cloudtrail"
# }


# module "cloudwatch" {
#   source = "./cloudwatch"

#   load_balancer_arn = module.webserver-lb.webserver_lb_dns_arn
#   asg_name          = module.webserver-asg.asg_name
# }

# module "efs" {
#   source = "./efs"

#   backend_sg      = module.securitygroups.backendserver_security_group # in outputs
#   backend_subnets = [module.networking.health_subnets_a[1], module.networking.health_subnets_b[1]]
# }