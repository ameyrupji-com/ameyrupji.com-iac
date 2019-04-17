output "api-gateway-resource-id" {
  value = "${aws_api_gateway_resource.api_gateway_resource.id}"
}

output "aws-api-gateway-resource-path" {
  value = "${aws_api_gateway_resource.api_gateway_resource.path}"
}
