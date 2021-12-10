# --- root/provoders.tf ---

provider "aws" {
  region = local.region
  # Use profile (not ceredentials) because of security reasons
  # Profile has to be in ~/.aws/credentials file
  profile = "Capaimee"
  # might want to specify a version = "~> 3.0" 
}