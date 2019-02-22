
# State Bucket 
resource "aws_s3_bucket" "domain_iac_s3_bucket" {
  bucket              = "${var.domain}-iac"

  versioning {
    enabled           = true
  }

  tags {
    Name              = "${var.domain}-iac"
  }
}

# DynamoDb State
# resource "aws_dynamodb_table" "domain_iac_terraform_state" {
#   name           = "${var.domain}-terraform-state-file-locking"
#   hash_key       = "LockID"
#   billing_mode   = "PAY_PER_REQUEST" 

#   attribute {
#     name        = "LockID"
#     type        = "S"
#   }

#   tags {
#     Name        = "${var.domain}-terraform-state-file-locking"
#   }
# }