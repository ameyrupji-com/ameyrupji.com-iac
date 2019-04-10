resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = "${var.api-gateway-rest-api-id}"
  parent_id   = "${var.resource-parent-id}"
  path_part   = "${var.path-part}"
}

resource "aws_api_gateway_method" "gateway_method" {
  rest_api_id   = "${var.api-gateway-rest-api-id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_api_gateway_integration" {
  rest_api_id = "${var.api-gateway-rest-api-id}"
  resource_id = "${aws_api_gateway_method.gateway_method.resource_id}"
  http_method = "${aws_api_gateway_method.gateway_method.http_method}"
  type        = "MOCK"

  depends_on = ["aws_api_gateway_method.gateway_method"]
}

resource "aws_api_gateway_method_response" "gateway_method_200" {
  rest_api_id = "${var.api-gateway-rest-api-id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.gateway_method.http_method}"
  status_code = 200

  response_models {
    "application/json" = "Empty"
  }

  response_parameters {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = ["aws_api_gateway_method.gateway_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response" {
  rest_api_id = "${var.api-gateway-rest-api-id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_resource.id}"
  http_method = "${aws_api_gateway_method.gateway_method.http_method}"
  status_code = "${aws_api_gateway_method_response.gateway_method_200.status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.gateway_method_200"]
}
