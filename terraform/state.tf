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

# verify if this works
# terraform {
#   backend "s3" {}
# }

# data "terraform_remote_state" "state" {
#   backend = "s3"
#   config {
#     bucket     = "${var.state_bucket}"
#     lock_table = "${var.state_table}"
#     region     = "${var.region}"
#     key        = "${var.application}/${var.environment}"
#   }
# }

# terraform init \ 
#      -backend-config "bucket=$TF_VAR_tf_state_bucket" \ 
#      -backend-config "lock_table=$TF_VAR_tf_state_table" \ 
#      -backend-config "region=$TF_VAR_region" \ 
#      -backend-config "key=$TF_VAR_application/$TF_VAR_environment"
