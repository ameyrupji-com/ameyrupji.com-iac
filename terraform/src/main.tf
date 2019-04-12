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

module "post_email_lambda" {
  source = "./modules/api_lambda_with_logging"

  lambda-name      = "${var.post-email-lambda-name}"
  lambda-file-name = "${var.post-email-lambda-file-name}"

  lambda-version     = "${var.lambda-version}"
  assets-bucket-name = "${var.assets-bucket-name}"

  custom-policy = {
    name        = "${var.post-email-lambda-name}-ses-send-email-access"
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

module "get_root_lambda" {
  source = "./modules/api_lambda_with_logging"

  lambda-name      = "${var.get-root-lambda-name}"
  lambda-file-name = "${var.get-root-lambda-file-name}"

  lambda-version     = "${var.lambda-version}"
  assets-bucket-name = "${var.assets-bucket-name}"
}

resource "aws_api_gateway_rest_api" "domain_api_gateway" {
  name        = "${var.api-gateway-name}-api-gateway"
  description = "Api gateway for ${var.api-domain}"
}

# module "get_root_resource" {
#   source = "./modules/api_gateway_resource"


#   region                     = "${var.region}"
#   path                       = "/{proxy+}"
#   path-part                  = "{proxy+}"
#   http-method                = "GET"
#   resource-parent-id         = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
#   lambda-function-arn        = "${module.get_root_lambda.lambda-arn}"
#   lambda-function-invoke-arn = "${module.get_root_lambda.lambda-invoke-arn}"
#   api-gateway-rest-api-id    = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
# }


# module "option_root_resource" {
#   source = "./modules/options_api_gateway_resource"


#   path-part               = "{proxy+}"
#   resource-parent-id      = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
#   api-gateway-rest-api-id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
# }


# module "post_email_resource" {
#   source = "./modules/api_gateway_resource"


#   region                     = "${var.region}"
#   path                       = "/email"
#   path-part                  = "email"
#   http-method                = "POST"
#   resource-parent-id         = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
#   lambda-function-arn        = "${module.post_email_lambda.lambda-arn}"
#   lambda-function-invoke-arn = "${module.post_email_lambda.lambda-invoke-arn}"
#   api-gateway-rest-api-id    = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
# }


# module "option_email_resource" {
#   source = "./modules/options_api_gateway_resource"


#   path-part               = "email"
#   resource-parent-id      = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
#   api-gateway-rest-api-id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
# }


# module "domain_api_gateway" {
#   source = "./modules/domain_api_gateway"


#   domain                  = "${var.domain}"
#   api-domain              = "${var.api-domain}"
#   api-subdomain           = "${var.api-subdomain}"
#   certificate-domain      = "${var.certificate-domain}"
#   api-gateway-rest-api-id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   api-gateway-stage-name  = "${var.api-gateway-stage-name}"
# }

