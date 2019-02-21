# creating bucket
resource "aws_s3_bucket" "static_web_hosting_s3_bucket" {
  bucket = "${var.bucket_name}"
}

# creating bucket public read policy
resource "aws_s3_bucket_policy" "static_web_hosting_s3_bucket_policy" {
  bucket = "${aws_s3_bucket.static_web_hosting_s3_bucket.id}"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
POLICY
}


data "aws_route53_zone" "static_website_route53_zone" {
  name = "${var.domain}."
}

resource "aws_route53_record" "static_website_route53_record" {
  zone_id = "${data.aws_route53_zone.static_website_route53_zone.id}"
  name    = "${var.subdomain}"
  type    = "A"

  alias {
    name    = "${data.aws_s3_bucket.static_web_hosting_s3_bucket.website_domain}"
    zone_id = "${data.aws_s3_bucket.static_web_hosting_s3_bucket.hosted_zone_id}"
  }
}
