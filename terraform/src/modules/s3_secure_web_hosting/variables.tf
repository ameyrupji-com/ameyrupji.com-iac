variable "domain" {}

variable "subdomain" {}

variable "bucket-name" {}

variable "certificate-domain" {
  description = "Wildcard SSL certificate domain name.  E.g. *.example.com"
  default     = ""
}

variable "aliases" {
  description = "Additional aliases to host this website for."
  default     = []
}

variable "cache-ttl" {
  description = "Default TTL to give objects requested from S3 in CloudFront for caching."
  default     = 3600
}

variable "price-class" {
  description = "Which price class to enable in CloudFront. "
  default     = "PriceClass_100"
}
