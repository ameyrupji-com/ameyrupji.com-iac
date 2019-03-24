output "lambda-arn" {
  value = "${aws_lambda_function.lambda_function.arn}"
}

output "lambda-invoke-arn" {
  value = "${aws_lambda_function.lambda_function.invoke_arn}"
}
