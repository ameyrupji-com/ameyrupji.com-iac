# resource "aws_iam_role" "domain_api_gateway_coudwatch_log_role" {
#   name = "${var.domain}-cloudwatch-log-role"
# }

# resource "aws_iam_policy_attachment" "domain_api_gateway_coudwatch_role_policy_attachment" {
#   name       = "${var.domain}-cloudwatch-log-role-policy-attachment"
#   roles      = ["${aws_iam_role.domain_api_gateway_coudwatch_log_role.name}"]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
# }

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = var.api-gateway-rest-api-id
  stage_name  = var.api-gateway-stage-name
}

data "aws_route53_zone" "domain_rout53_zone" {
  name = "${var.domain}."
}

data "aws_acm_certificate" "domain_certificate" {
  domain   = var.certificate-domain
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
  domain_name              = var.api-domain
  regional_certificate_arn = data.aws_acm_certificate.domain_certificate.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api_gateway_route53_record" {
  zone_id = data.aws_route53_zone.domain_rout53_zone.zone_id
  name    = var.api-subdomain
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_gateway_domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_domain_name.regional_zone_id
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_base_path_mapping" "api_gateway_base_path_mapping" {
  depends_on = [
    aws_api_gateway_deployment.api_gateway_deployment,
  ]

  api_id      = var.api-gateway-rest-api-id
  stage_name  = var.api-gateway-stage-name
  domain_name = aws_api_gateway_domain_name.api_gateway_domain_name.domain_name
}
