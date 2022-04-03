# Apply this Terraform config in the account where the shared bucket will reside.

terraform {
  required_version = ">= 1.1.0, < 1.2.0"
  required_providers {
    aws = {
      version = ">=4.1.0, <5.0.0"
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_s3_bucket" "shared" {
  bucket = var.bucket_name
}

# The following aws_s3_bucket_server_side_encryption_configuration and
# aws_s3_bucket_public_access_block resources aren't mandated but good pratice.

resource "aws_s3_bucket_server_side_encryption_configuration" "shared" {
  bucket = aws_s3_bucket.shared.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "shared" {
  bucket = aws_s3_bucket.shared.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# This bucket policy allows the other account to get, put and delete objects
# in the bucket.

resource "aws_s3_bucket_policy" "shared" {
  bucket = aws_s3_bucket.shared.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "AWS": [${join(",", var.share_to_role_arns)}]
          },
          "Action": [
              "s3:GetObject",
              "s3:GetObjectAcl",
              "s3:PutObjectAcl",
              "s3:DeleteObject"
          ],
          "Resource": ["${aws_s3_bucket.shared.arn}/*"]
      },
      {
          "Effect": "Allow",
          "Principal": {
              "AWS": [${join(",", var.share_to_role_arns)}]
          },
          "Action": [
              "s3:List*"
          ],
          "Resource": [
            "${aws_s3_bucket.shared.arn}",
            "${aws_s3_bucket.shared.arn}/*"
          ]
      },
      {
         "Sid": "Only allow writes to bucket with bucket owner full control",
         "Effect": "Allow",
         "Principal": {
            "AWS": [${join(",", var.share_to_role_arns)}]
         },
         "Action": [
            "s3:PutObject"
         ],
         "Resource": ["${aws_s3_bucket.shared.arn}/*"],
         "Condition": {
            "StringEquals": {
               "s3:x-amz-acl": "bucket-owner-full-control"
            }
         }
      }
   ]
}
POLICY
}
