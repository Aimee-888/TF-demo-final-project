# --- route53/main.tf ---


# ========= Hosted Zone ============
resource "aws_route53_zone" "try" {
  name    = var.hosted_zone_name
  comment = "Provided by TF"
}


# ======== Records ==========
# Name Server Records - Specify Zone-ID
resource "aws_route53_record" "primary" {
  allow_overwrite = true
  name            = var.hosted_zone_name
  ttl             = 60
  type            = "NS"
  # zone_id         = var.hosted_zone_id
  zone_id = aws_route53_zone.try.zone_id

  # records = var.domain_ns_records

  records = [
    aws_route53_zone.try.name_servers[0],
    aws_route53_zone.try.name_servers[1],
    aws_route53_zone.try.name_servers[2],
    aws_route53_zone.try.name_servers[3],
  ]
}

#Record resource
resource "aws_route53_record" "www" {
  name = join("", ["www.", "${var.hosted_zone_name}"])
  # zone_id = var.hosted_zone_id
  zone_id = aws_route53_zone.try.zone_id
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "no-prefix" {
  # name   = var.hosted_zone_name
  name = join("", ["", "${var.hosted_zone_name}"])
  # zone_id = var.hosted_zone_id
  zone_id = aws_route53_zone.try.zone_id
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}



### ===== Cert Manager ======= 
# source: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate

# Create simple cert 
resource "aws_acm_certificate" "cert" {
  domain_name       = "www.aimees-tameshi.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Add Cnames to hosted Zone
resource "aws_route53_record" "cert-cnames" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.try.zone_id
}