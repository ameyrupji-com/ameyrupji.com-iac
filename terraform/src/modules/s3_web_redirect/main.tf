# creating redirect requuest bucket
resource "aws_s3_bucket" "static_web_hosting_s3_bucket" {
  bucket = "${var.bucket_name}"

  website {
    redirect_all_requests_to = "${var.redirect_bucket_name}"
  }

  tags {
    Name = "${var.bucket_name}"
  }
}
