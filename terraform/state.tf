terraform {
  backend "s3" {
    bucket        = "ameyrupji"
    key           = "terraform/tfstate/state.tfstate"
    region        = "us-east-1"
    encrypt       = "true"
    profile       = "saml"
  }

  required_version = "0.11.10"
}
