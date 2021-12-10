# --- S3bucket/main.tf ---

resource "aws_s3_bucket" "log_bucket" {
  bucket = "bucket88888files"
  acl    = "private"

  tags = {
    Name = "bucket-for-filesfp233f2p"
  }

  versioning {
    enabled = true
  }



  # Lifecycle Rule 
  lifecycle_rule {
    id      = ""
    enabled = true

    tags = {
      rule      = "log"
      autoclean = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

}