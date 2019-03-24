# bucket for main subdomain 
module "s3_domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "${var.main-subdomain}"
  domain      = "${var.domain}"
  bucket_name = "${var.main-domain}"
}

# bucket for alternate subdomain
module "s3_www_domain" {
  source = "./modules/s3_web_redirect"

  subdomain            = "${var.alternate-subdomain}"
  domain               = "${var.domain}"
  bucket_name          = "${var.alternate-domain}"
  redirect_bucket_name = "${var.main-domain}"
}

# bucket for code subdomain
module "s3_code_domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "${var.code-subdomain}"
  domain      = "${var.domain}"
  bucket_name = "${var.code-domain}"
}

# bucket for blog subdomain
module "s3_blog_domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "${var.blog-subdomain}"
  domain      = "${var.domain}"
  bucket_name = "${var.blog-domain}"
}

# bucket for images subdomain
module "s3_images_domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "${var.images-subdomain}"
  domain      = "${var.domain}"
  bucket_name = "${var.images-domain}"
}

module "email_lambda" {
  source = "./modules/api_lambda_with_logging"

  lambda-name      = "${var.email-lambda-name}"
  lambda-file-name = "${var.email-lambda-file-name}"

  lambda-version     = "${var.lambda-version}"
  assets-bucket-name = "${var.assets-bucket-name}"

  custom-policy = {
    name        = "${var.email-lambda-name}-ses-send-email-access"
    description = "SES email policy"

    document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SESSendEmailAccess",
      "Effect": "Allow",
      "Action": "ses:SendEmail",
      "Resource": "*"
    }
  ]
}
EOF
  }
}

# api to send emails
resource "aws_api_gateway_rest_api" "domain_api_gateway" {
  name        = "${var.name}-api-gateway"
  description = "Api gateway for ${var.api-domain}"
}

module "domain-api-gateway" {
  source = "./modules/domain_api_gateway"

  domain                            = "${var.domain}"
  api-domain                        = "${var.api-domain}"
  certificate-domain                = "${var.certificate-domain}"
  api-gateway-rest-api-id           = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  api-gateway-deployment-stage-name = "${var.api-gateway-stage-name}"
}

module "post-email-resource" {
  source = "./modules/api_gateway_resource"

  path                              = "/email"
  path-part                         = "email"
  http_method                       = "POST"
  resource-parent-id                = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
  lambda-function-arn               = "${module.email_lambda.lambda-arn}"
  api-gateway-rest-api-id           = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  api-gateway-deployment-stage-name = "${var.api-gateway-stage-name}"
}
