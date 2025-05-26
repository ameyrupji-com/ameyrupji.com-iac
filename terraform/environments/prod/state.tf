terraform {
  backend "s3" {
    bucket  = "ameyrupji.com-iac"
    key     = "terrafrom/state.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }

  required_version = ">= 1.8.5"
}
