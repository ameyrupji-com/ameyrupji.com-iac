output "deployment_dependencies" {
  value = [
    "aws_api_gateway_method.gateway_method",
    "aws_api_gateway_integration.lambda_api_gateway_integration",
    "aws_api_gateway_method_response.gateway_method_200",
    "aws_api_gateway_integration_response.api_gateway_integration_response",
  ]
}
