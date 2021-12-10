
# --- cloudtrail/main.tf ---


# ========== ONLY COPY & PASTE ==============
# source: https://github.com/JacobHughes/terraform-auto-cloudtrail/blob/master/src/terraform/config.tf

variable "cloudtrail-s3-bucket" {
  description = "Bucket name to store cloudtrail logs"
  default     = "tac-master-cloudtrail-bucket"
}

variable "cloudtrail-access-log-bucket" {
  description = "Bucket name to store access logs of cloudtrail log bucket"
  default     = "tac-cloudtrail-access-log-bucket"
}

variable "env" {
  description = "Development environment e.g. 'dev' or 'prod'"
  default     = "dev"
}



/**
 * S3 Bucket for storing CloudTrail logs access logs
 */
resource "aws_s3_bucket" "cloudtrail-access-log-bucket" {
  bucket        = "${var.cloudtrail-access-log-bucket}-${var.env}"
  acl           = "log-delivery-write"
  force_destroy = true

}

/**
 * S3 bucket for storing CloudTrail logs
 * For terraform reasons, the policy needs to be detailed here, not in a separate
 * policy document and later attached.
 */
resource "aws_s3_bucket" "master-cloudtrail-bucket" {
  bucket        = "${var.cloudtrail-s3-bucket}-${var.env}"
  force_destroy = true

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.cloudtrail-access-log-bucket.id
    target_prefix = "log/"
  }


  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.cloudtrail-s3-bucket}-${var.env}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.cloudtrail-s3-bucket}-${var.env}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

/**
 * CloudTrail resource for monitoring all services
 */
resource "aws_cloudtrail" "master_cloudtrail" {
  name                          = "master-cloudtrail-${var.env}"
  s3_bucket_name                = aws_s3_bucket.master-cloudtrail-bucket.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true
  is_multi_region_trail         = true

}


