# creating bucket
resource "aws_s3_bucket" "secure_web_hosting_s3_bucket" {
  bucket = "${var.bucket_name}"

  tags = {
    Name = "${var.bucket_name}"
  }
}

resource "aws_s3_bucket_policy" "secure_web_hosting_s3_bucket_policy" {
  bucket = "${aws_s3_bucket.secure_web_hosting_s3_bucket.id}"
  policy = "${data.aws_iam_policy_document.secure_web_hosting_s3_bucket_policy_document.json}"
}


data "aws_iam_policy_document" "secure_web_hosting_s3_bucket_policy_document" {
  statement {
    sid    = "DenyInsecure"
    effect = "Deny"

    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.secure_web_hosting_s3_bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false "]
    }
  }

  statement {
    sid    = "AllowCloudFrontObjectRead"
    effect = "Allow"

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.secure_web_hosting_s3_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.secure_web_aws_cloudfront_origin_access_identity.iam_arn}"]
    }
  }

  statement {
    sid    = "AllowCloudFrontBucketList"
    effect = "Allow"

    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.secure_web_hosting_s3_bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.secure_web_aws_cloudfront_origin_access_identity.iam_arn}"]
    }
  }
}


