# creating redirect requuest bucket
resource "aws_s3_bucket" "static_web_hosting_s3_bucket" {
  bucket = var.bucket_name

  website {
    redirect_all_requests_to = var.redirect_bucket_name
    # Deprecated, but no replacement block for aws_s3_bucket as of Terraform AWS provider 5.x
  }

  tags = {
    Name = var.bucket_name
  }
}

data "aws_route53_zone" "static_website_rout53_zone" {
  name = var.domain
}

resource "aws_route53_record" "static_website_route53_record" {
  zone_id = data.aws_route53_zone.static_website_rout53_zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_s3_bucket.static_web_hosting_s3_bucket.website_domain
    zone_id                = aws_s3_bucket.static_web_hosting_s3_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}
