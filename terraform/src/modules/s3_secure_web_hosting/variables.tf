variable "domain" {}

variable "subdomain" {}

variable "bucket_name" {}

variable "certificate_domain" {
  description = "SSL certificate domain name.  E.g. *.example.com"
  default     = ""
}

variable "cache_ttl" {
  description = "Default TTL to give objects requested from S3 in CloudFront for caching."
  default     = 3600
}

variable "price_class" {
  description = "Which price class to enable in CloudFront. "
  default     = "PriceClass_100"
}
