# --- securitygroups/main.tf ---

# ======= Security Group =======

# Dynamic Block, configure new SG in root/locals.tf
resource "aws_security_group" "sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }

  }
  egress {
    from_port = 0
    to_port   = 0
    # -1 menas "everything"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]


  }
}

