data "aws_route53_zone" "secure_web_rout53_zone" {
  name = var.domain
}

resource "aws_route53_record" "secure_web_route53_record" {
  zone_id = data.aws_route53_zone.secure_web_rout53_zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.secure_web_cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.secure_web_cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
