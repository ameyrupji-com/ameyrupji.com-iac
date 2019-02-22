provider "aws" {
  region = "${var.region}"
}

module "domain_state" {
  source = "./modules/state"

  domain = "${var.domain}"
}

terraform {
  backend "s3" {
    bucket  = "ameyrupji.com-iac"
    key     = "/terrafrom/state.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }

  required_version = "0.11.10"
}

# bucket for domain.com
module "s3-domain-com" {
  source = "./modules/s3_web_hosting"

  subdomain   = ""
  domain      = "${var.domain}"
  bucket_name = "${var.domain}"
}

# bucket for beta.domain.com
module "s3-beta-domain-com" {
  source = "./modules/s3_web_hosting"

  subdomain   = "beta"
  domain      = "${var.domain}"
  bucket_name = "beta.${var.domain}"
}

# bucket for www.domain.com
module "s3-www-domain-com" {
  source = "./modules/s3_web_hosting"

  subdomain   = "www"
  domain      = "${var.domain}"
  bucket_name = "www.${var.domain}"
}

# bucket for code.domain.com
module "s3-code-domain-com" {
  source = "./modules/s3_web_hosting"

  subdomain   = "code"
  domain      = "${var.domain}"
  bucket_name = "code.${var.domain}"
}

# bucket for blog.domain.com
module "s3-blog-domain-com" {
  source = "./modules/s3_web_hosting"

  subdomain   = "blog"
  domain      = "${var.domain}"
  bucket_name = "blog.${var.domain}"
}
