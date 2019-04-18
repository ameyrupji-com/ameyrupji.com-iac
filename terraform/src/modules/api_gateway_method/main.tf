resource "aws_api_gateway_method" "gateway_method" {
  rest_api_id   = "${var.api-gateway-rest-api-id}"
  resource_id   = "${var.api-gateway-resource-id}"
  http_method   = "${var.http-method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_api_gateway_integration" {
  rest_api_id = "${var.api-gateway-rest-api-id}"
  resource_id = "${aws_api_gateway_method.gateway_method.resource_id}"
  http_method = "${aws_api_gateway_method.gateway_method.http_method}"

  integration_http_method = "${var.http-method}"
  type                    = "AWS"
  uri                     = "${var.lambda-function-invoke-arn}"

  request_templates = {
    "application/json" = ""
  }

  depends_on = ["aws_api_gateway_method.gateway_method"]
}

resource "aws_api_gateway_method_response" "gateway_method_200" {
  rest_api_id = "${var.api-gateway-rest-api-id}"
  resource_id = "${var.api-gateway-resource-id}"
  http_method = "${aws_api_gateway_method.gateway_method.http_method}"
  status_code = "200"
  depends_on  = ["aws_api_gateway_method.gateway_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response" {
  depends_on = [
    "aws_api_gateway_integration.lambda_api_gateway_integration",
  ]

  rest_api_id = "${var.api-gateway-rest-api-id}"
  resource_id = "${var.api-gateway-resource-id}"
  http_method = "${aws_api_gateway_method.gateway_method.http_method}"
  status_code = "${aws_api_gateway_method_response.gateway_method_200.status_code}"

  response_templates {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method_response.gateway_method_200"]
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "lambda_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda-function-arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.api-gateway-rest-api-id}/*/POST${var.path}"
}
