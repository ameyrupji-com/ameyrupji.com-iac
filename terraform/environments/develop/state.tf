terraform {
  backend "s3" {
    bucket  = "ameyrupji.com-iac"
    key     = "terrafrom/state-beta.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }

  required_version = "0.11.10"
}
