# creating simple bucket for storage of data
resource "aws_s3_bucket" "storage_s3_bucket" {
  bucket = "${var.bucket_name}"

  tags {
    Name = "${var.bucket_name}"
  }
}
