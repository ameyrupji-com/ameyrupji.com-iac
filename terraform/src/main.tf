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

# email lambda function
data "aws_iam_policy_document" "ses_send_iam_policy_document" {
  statement {
    sid       = "SESSendEmail"
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = "*"
  }
}

module "email_lambda" {
  source = "./modules/api_lambda_with_logging"

  lambda-name      = "${var.email-lambda-name}"
  lanbda-file-name = "${var.email-lambda-file-name}"

  lambda-version     = "${var.lambda-version}"
  assets-bucket-name = "${var.assets-bucket-name}"

  custom-policy = {
    name        = "${var.email-lambda-name}-ses-send-email-access"
    description = "SES email policy"
    document    = "${data.aws_iam_policy_document.ses_send_iam_policy_document.json}"
  }
}

# # api to send emails
# resource "aws_api_gateway_rest_api" "domain_api_gateway" {
#   name        = "${var.name}-api-gateway"
#   description = "Api gateway for api.${var.domain}"
# }

# resource "aws_api_gateway_resource" "email_api_gateway_resource" {
#   rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   parent_id   = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
#   path_part   = "email"
# }

# resource "aws_api_gateway_method" "email_gateway_method" {
#   rest_api_id   = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   resource_id   = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
#   http_method   = "POST"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "email_lambda_api_gateway_integration" {
#   rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   resource_id = "${aws_api_gateway_method.email_gateway_method.resource_id}"
#   http_method = "${aws_api_gateway_method.email_gateway_method.http_method}"

#   integration_http_method = "POST"
#   type                    = "AWS"
#   uri                     = "${aws_lambda_function.lambda_function_email.invoke_arn}"

#   request_templates = {
#     "application/json" = ""
#   }
# }

# resource "aws_api_gateway_method_response" "email_gateway_method_200" {
#   rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   resource_id = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
#   http_method = "${aws_api_gateway_method.email_gateway_method.http_method}"
#   status_code = "200"
# }

# resource "aws_api_gateway_integration_response" "email_api_gateway_integration_response" {
#   depends_on = [
#     "aws_api_gateway_integration.email_lambda_api_gateway_integration",
#   ]

#   rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   resource_id = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
#   http_method = "${aws_api_gateway_method.email_gateway_method.http_method}"
#   status_code = "${aws_api_gateway_method_response.email_gateway_method_200.status_code}"

#   response_templates {
#     "application/json" = ""
#   }
# }

# resource "aws_api_gateway_deployment" "domain_api_gateway_deployment" {
#   depends_on = [
#     "aws_api_gateway_method.email_gateway_method",
#     "aws_api_gateway_integration.email_lambda_api_gateway_integration",
#     "aws_api_gateway_method_response.email_gateway_method_200",
#     "aws_api_gateway_integration_response.email_api_gateway_integration_response",
#   ]

#   rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   stage_name  = "prod"
# }

# data "aws_caller_identity" "current" {}

# resource "aws_lambda_permission" "email_lambda_api_gateway_permission" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.lambda_function_email.arn}"
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_deployment.domain_api_gateway_deployment.rest_api_id}/*/POST/${aws_api_gateway_resource.email_api_gateway_resource.path_part}"
# }

# data "aws_route53_zone" "static_website_rout53_zone" {
#   name = "${var.domain}."
# }

data "aws_acm_certificate" "domain_certificate" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]
}

# resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
#   domain_name              = "api.${var.domain}"
#   regional_certificate_arn = "${data.aws_acm_certificate.domain_certificate.arn}"


#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }


# resource "aws_route53_record" "api_gateway_route53_record" {
#   zone_id = "${data.aws_route53_zone.static_website_rout53_zone.zone_id}"
#   name    = "api"
#   type    = "A"


#   alias {
#     name                   = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_domain_name}"
#     zone_id                = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_zone_id}"
#     evaluate_target_health = true
#   }
# }


# resource "aws_api_gateway_base_path_mapping" "api_gateway_base_path_mapping" {
#   api_id      = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
#   stage_name  = "${aws_api_gateway_deployment.domain_api_gateway_deployment.stage_name}"
#   domain_name = "${aws_api_gateway_domain_name.api_gateway_domain_name.domain_name}"
# }

