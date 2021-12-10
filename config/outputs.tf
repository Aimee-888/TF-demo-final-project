# --- aws_config/outputs.tf ---
output "config_log_bucket_arn" {
  value = aws_s3_bucket.my-config.arn

}