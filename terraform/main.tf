provider "aws" {
  region = "${var.region}"
}

# module "domain_iac" {
#   source = "./modules/iac"

#   domain = "${var.domain}"
# }

terraform {
  backend "s3" {
    bucket  = "ameyrupji.com-iac"
    key     = "terrafrom/state.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }

  required_version = "0.11.10"
}

# bucket for domain.com
module "s3-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = ""
  bucket_name = "${var.domain}"
}

# bucket for beta.domain.com
module "s3-beta-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "beta"
  bucket_name = "beta.${var.domain}"
}

# bucket for www.domain.com
module "s3-www-domain" {
  source = "./modules/s3_web_redirect"

  bucket_name          = "www.${var.domain}"
  redirect_bucket_name = "${var.domain}"
}

# bucket for code.domain.com
module "s3-code-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "code"
  bucket_name = "code.${var.domain}"
}

# bucket for blog.domain.com
module "s3-blog-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "blog"
  bucket_name = "blog.${var.domain}"
}

# bucket for images.domain.com
module "s3-images-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "images"
  bucket_name = "images.${var.domain}"
}
