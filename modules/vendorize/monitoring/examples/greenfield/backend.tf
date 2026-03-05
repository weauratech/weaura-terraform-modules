terraform {
  backend "s3" {
    bucket = "aura-tfstates"
    key    = "vendorize/greenfield/terraform.tfstate"
    region = "us-east-2"
  }
}
