# --- aws_config/main.tf ---

# resource: http://100daysofdevops.com/21-days-of-aws-using-terraform-day-16-introduction-to-aws-config-using-terraform/

# ============ S3 Log Bucket ==========
resource "aws_s3_bucket" "my-config" {
  bucket = var.config_logs_bucket
  acl    = "private"

  force_destroy = true

  versioning {
    enabled = true
  }

  # In PROD you may want to comment our "force_destroy" and add this statement to protect your bucket from deletion
  # lifecycle {
  #   prevent_destroy = true
  # }
}


# ================ AWS Config Permissions (IAM) ======================
resource "aws_iam_role" "my-config" {
  name = "config-example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "my-config" {
  role       = aws_iam_role.my-config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

# source: https://github.com/hashicorp/terraform-provider-aws/issues/8655
# added to fix delivery channel problem (aws_config)

resource "aws_iam_role_policy" "p" {
  name = "awsconfig-log-bucket-perm"
  role = aws_iam_role.my-config.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.my-config.arn}",
        "${aws_s3_bucket.my-config.arn}/*"
      ]
    }
  ]
}
POLICY
}


# # ============= AWS Config Initialiesierung ========
# otherwise had to be created in console - Starting Block
resource "aws_config_configuration_recorder" "my-config" {
  name     = "config-example"
  role_arn = aws_iam_role.my-config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}



# ========= Delivery Channel ===========
# to deliver configuration information to an Amazon S3 bucket or Amazon SNS topic
# See in console: Config/Settings/Delivery_Channel 
resource "aws_config_delivery_channel" "my-config" {
  name           = "config-delivery-channel-docs"
  s3_bucket_name = aws_s3_bucket.my-config.bucket
  depends_on     = [aws_config_configuration_recorder.my-config]
}

resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.my-config.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.my-config]
}


# ========= Config Rules ============

# source: https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html

resource "aws_config_config_rule" "cloud_trail_enabled" {
  name = "cloud_trail_enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"

    # not allowed because it is an aws managed rule.... 
    # source_detail {
    #   maximum_execution_frequency = "One_Hour"
    # }
  }

  input_parameters = <<EOF
{ "s3BucketName": "tac-cloudtrail-access-log-bucket-dev" }
EOF

  depends_on = [aws_config_configuration_recorder.my-config]
}

resource "aws_config_config_rule" "restricted-ssh" {
  name = "restricted_ssh"
  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder.my-config]
}

resource "aws_config_config_rule" "s3bucket_versioning" {
  name = "S3_bucket_versioning_enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.my-config]
}