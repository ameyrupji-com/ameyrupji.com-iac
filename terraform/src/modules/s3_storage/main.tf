# creating redirect requuest bucket
resource "aws_s3_bucket" "storage_s3_bucket" {
  bucket = "${var.bucket_name}"

  tags {
    Name = "${var.bucket_name}"
  }
}
