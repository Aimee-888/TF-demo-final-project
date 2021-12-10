# --- root/locals.tf ---

locals {
  vpc_cidr = "10.11.0.0/16"
}

locals {
  region = "eu-west-2"
}

locals {
  security_groups = {

    bastionhost = {
      name        = "bastionhost_sg"
      description = "SG for Bastionhost"
      ingress = {
        shh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
      }
    }

    webserver = {
      name        = "webserver_sg"
      description = "SG for Webserver"
      ingress = {
        shh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip, "10.11.0.169/32"]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }

    webserver_lb = {
      name        = "webserver_lg_sg"
      description = "SG for Loadbalancer"
      ingress = {
        shh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }

    backendserver = {
      name        = "backendserver_sg"
      description = "SG for Backendserver"
      ingress = {
        # I dont know which port to open for webserver yet

        efs = {
          from        = 2049
          to          = 2049
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        ssh = {
          from     = 22
          to       = 22
          protocol = "tcp"
          # bastion host ip 
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }

    backendserver_lb = {
      name        = "backendserver_lb_sg"
      description = "SG for Wackendserver"
      ingress = {
        # I dont know which port to open for webserver yet

        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    rds = {
      name        = "rds_sg"
      description = "sg_for_rds_instance"
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}