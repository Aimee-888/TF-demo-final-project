# --- iam/outputs.tf ---

output "s3iam_instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.arn

}


