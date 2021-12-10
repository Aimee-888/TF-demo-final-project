# --- compute/outputs.tf ---

output "ami" {
  value = data.aws_ami.webserver_ami.id
}

output "key" {
  value = aws_key_pair.webserver_auth.id
}