data "aws_iam_policy_document" "lambda_asume_role_iam_policy_document" {
  statement {
    sid     = "LambdaAsumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "apigateway.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "lambda_exec_iam_role" {
  name               = "${var.lambda-name}-lambda-iam-role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_asume_role_iam_policy_document.json}"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.lambda-name}-lambda-function"

  s3_bucket = "${var.assets-bucket-name}"
  s3_key    = "${var.lambda-version}/${var.lambda-file-name}.py.zip"
  handler   = "${var.lambda-file-name}.lambda_handler"
  runtime   = "python3.12"

  role = "${aws_iam_role.lambda_exec_iam_role.arn}"

  source_code_hash = "${filebase64sha256("../../code/lambdas/${var.lambda-file-name}.py")}"

  lifecycle {
    ignore_changes = ["last_modified"]
  }
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 7
}

data "aws_iam_policy_document" "lambda_logging_iam_policy_document" {
  statement {
    sid    = "LambdaLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "lambda_logging_iam_policy" {
  name        = "${var.lambda-name}-lambda-logging-iam-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda ${var.lambda-name}"
  policy      = "${data.aws_iam_policy_document.lambda_logging_iam_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_iam_role_policy_attachment_logging" {
  role       = "${aws_iam_role.lambda_exec_iam_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_iam_policy.arn}"
}

resource "aws_iam_policy" "custom_iam_policy" {
  count = "${((var.custom-policy["name"] == "" ? 0 : 1) * (var.custom-policy["document"] == "" ? 0 : 1))}"

  name        = "${var.custom-policy["name"]}"
  path        = "/"
  description = "${var.custom-policy["description"]}"
  policy      = "${var.custom-policy["document"]}"
}

resource "aws_iam_role_policy_attachment" "custom_iam_role_policy_attachment" {
  count = "${((var.custom-policy["name"] == "" ? 0 : 1) * (var.custom-policy["document"] == "" ? 0 : 1))}"

  role       = "${aws_iam_role.lambda_exec_iam_role.name}"
  policy_arn = "${aws_iam_policy.custom_iam_policy[0].arn}"
}
