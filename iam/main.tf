# --- iam/main.tf ---

# reference: 
# https://devopslearning.medium.com/aws-iam-ec2-instance-role-using-terraform-fa2b21488536






# ===== S3 Permmissions for Backend-Server (Role, Instance Profile, Role Policy )===========
resource "aws_iam_role" "instance" {
  name = "S3forEC2_role"
  # policy that grants an entity permission to assume the role
  # This is going to create IAM role but we can’t link this role to 
  # AWS instance and for that, we need EC2 instance Profile
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = { tag-key = "tag-value" }
}

# EC2 Instance Profile
# This has to be set in Launch Template for ASG 
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.instance.name
}

# still permissions lacking 
# IAM Inline Policy for full access to S3 bucket
resource "aws_iam_role_policy" "test_policy" {
  name = "S3FullAccessInlinePolicy"
  role = aws_iam_role.instance.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
