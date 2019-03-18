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
  domain      = "${var.domain}"
  bucket_name = "${var.domain}"
}

# bucket for beta.domain.com
module "s3-beta-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "beta"
  domain      = "${var.domain}"
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
  domain      = "${var.domain}"
  bucket_name = "code.${var.domain}"
}

# bucket for blog.domain.com
module "s3-blog-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "blog"
  domain      = "${var.domain}"
  bucket_name = "blog.${var.domain}"
}

# bucket for images.domain.com
module "s3-images-domain" {
  source = "./modules/s3_web_hosting"

  subdomain   = "images"
  domain      = "${var.domain}"
  bucket_name = "images.${var.domain}"
}

# email lambda function
resource "aws_iam_role" "lambda_exec_email" {
  name = "${var.name}-email-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LambdaAsumeRole",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_function_email" {
  function_name = "${var.name}-email-lambda"

  s3_bucket = "${var.domain}-assets"
  s3_key    = "${var.email-lambda-version}/email-lambda.py.zip"
  handler   = "email-lambda.lambda_handler"
  runtime   = "python3.7"

  role = "${aws_iam_role.lambda_exec_email.arn}"

  source_code_hash = "${base64sha256(file("../code/lambdas/zipped/email-lambda.py.zip"))}"
}

resource "aws_cloudwatch_log_group" "email_lambda_cloudwatch_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function_email.function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.lambda_exec_email.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_iam_policy" "ses_access" {
  name        = "ses_send_email_access"
  path        = "/"
  description = "IAM policy for sending emails from a lambda"

  policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "email_lambda_ses_policy" {
  role       = "${aws_iam_role.lambda_exec_email.name}"
  policy_arn = "${aws_iam_policy.ses_access.arn}"
}

# api to send emails
resource "aws_api_gateway_rest_api" "domain_api_gateway" {
  name        = "${var.name}-api-gateway"
  description = "Api gateway for api.${var.domain}"
}

resource "aws_api_gateway_resource" "email_api_gateway_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.domain_api_gateway.root_resource_id}"
  path_part   = "email"
}

resource "aws_api_gateway_method" "email_gateway_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "email_lambda_api_gateway_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  resource_id = "${aws_api_gateway_method.email_gateway_method.resource_id}"
  http_method = "${aws_api_gateway_method.email_gateway_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.lambda_function_email.invoke_arn}"

  request_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "email_gateway_method_200" {
  rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.email_gateway_method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "email_api_gateway_integration_response" {
  depends_on = [
    "aws_api_gateway_integration.email_lambda_api_gateway_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.email_api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.email_gateway_method.http_method}"
  status_code = "${aws_api_gateway_method_response.email_gateway_method_200.status_code}"

  response_templates {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "domain_api_gateway_deployment" {
  depends_on = [
    "aws_api_gateway_method.email_gateway_method",
    "aws_api_gateway_integration.email_lambda_api_gateway_integration",
    "aws_api_gateway_method_response.email_gateway_method_200",
    "aws_api_gateway_integration_response.email_api_gateway_integration_response",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.domain_api_gateway.id}"
  stage_name  = "prod"
}

resource "aws_lambda_permission" "email_lambda_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function_email.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.domain_api_gateway.arn}/*/${aws_api_gateway_method.email_gateway_method.http_method}/${aws_api_gateway_resource.email_api_gateway_resource.path_part}"
}

# data "aws_route53_zone" "static_website_rout53_zone" {
#   name = "${var.domain}."
# }


# resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
#   domain_name = "api.${var.domain}"


#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }


# resource "aws_route53_record" "api_gateway_route53_record" {
#   name    = "${aws_api_gateway_domain_name.api_gateway_domain_name.domain_name}"
#   type    = "A"
#   zone_id = "${aws_route53_zone.static_website_rout53_zone.zone_id}"


#   alias {
#     evaluate_target_health = true
#     name                   = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_domain_name}"
#     zone_id                = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_zone_id}"
#   }
# }

