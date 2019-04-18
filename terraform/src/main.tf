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

module "get_root_method" {
  source = "./modules/api_gateway_method"

  region                     = "${var.region}"
  path                       = "/"
  http-method                = "GET"
  lambda-function-arn        = "${module.get_root_lambda.lambda-arn}"
  lambda-function-invoke-arn = "${module.get_root_lambda.lambda-invoke-arn}"
  api-gateway-rest-api-id    = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  api-gateway-resource-id    = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
}

module "option_root_method" {
  source = "./modules/options_api_gateway_method"

  api-gateway-rest-api-id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  api-gateway-resource-id = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
}

resource "aws_api_gateway_resource" "email_api_gateway_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
  path_part   = "email"
}

module "post_email_method" {
  source = "./modules/api_gateway_method"

  region                     = "${var.region}"
  http-method                = "POST"
  path                       = "/${aws_api_gateway_resource.email_api_gateway_resource.path_part}"
  lambda-function-arn        = "${module.post_email_lambda.lambda-arn}"
  lambda-function-invoke-arn = "${module.post_email_lambda.lambda-invoke-arn}"
  api-gateway-rest-api-id    = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  api-gateway-resource-id    = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
}

module "option_email_method" {
  source = "./modules/options_api_gateway_method"

  api-gateway-rest-api-id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  api-gateway-resource-id = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
}

# module "deploy_domain_api_gateway" {
#   source = "./modules/deploy_domain_api_gateway"


#   # This is not working as terraform does not support inter midular dependancies 
#   # This is going to be enabled in v0.12 which is in beta at the point of this 
#   # development moving to use approach without modules
#   fake-dependancies = []


#   domain                  = "${var.domain}"
#   api-domain              = "${var.api-domain}"
#   api-subdomain           = "${var.api-subdomain}"
#   certificate-domain      = "${var.certificate-domain}"
#   api-gateway-rest-api-id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   api-gateway-stage-name  = "${var.api-gateway-stage-name}"
# }

