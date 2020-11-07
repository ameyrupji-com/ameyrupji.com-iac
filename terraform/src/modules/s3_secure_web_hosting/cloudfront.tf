data "aws_acm_certificate" "domain_certificate" {
  domain   = "${var.certificate_domain}"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_origin_access_identity" "secure_web_aws_cloudfront_origin_access_identity" {
  comment = "CloudFront OAI for (${var.domain})"
}

resource "aws_cloudfront_distribution" "secure_web_cloudfront_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2"

  #   aliases = ["${compact(concat(list(var.domain), var.aliases))}"]

  viewer_certificate {
    acm_certificate_arn      = "${data.aws_acm_certificate.domain_certificate.arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  origin {
    domain_name = "${aws_s3_bucket.secure_web_hosting_s3_bucket.bucket_domain_name}"
    origin_id   = "${aws_s3_bucket.secure_web_hosting_s3_bucket.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.secure_web_aws_cloudfront_origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.secure_web_hosting_s3_bucket.id}"

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = "${var.cache_ttl}"
    min_ttl     = "${(var.cache_ttl / 4) < 60 ? 0 : floor(var.cache_ttl / 4)}"
    max_ttl     = "${floor(var.cache_ttl * 24)}"

    forwarded_values {
      query_string = false

      headers = ["Origin"]

      cookies {
        forward = "none"
      }
    }
  }

  // 100: Limit to only Europe, USA, and Canada endpoints.
  // 200: + Hong Kong, Philippines, South Korea, Singapore, & Taiwan.
  // All: + South America, and Australa.
  price_class = "${var.price_class}"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}


