terraform {
  required_version = ">= 1.1.0, < 1.2.0"
  required_providers {
    aws = {
      version = ">=4.1.0, <5.0.0"
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_iam_role" "s3_cross_account_access" {
  name               = "s3-cross-account-access-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_cross_account_access" {
  role       = aws_iam_role.s3_cross_account_access.name
  policy_arn = aws_iam_policy.s3_shared_bucket.arn
}

# This policy provides access to the shared bucket in the other account.
# You can attach it to any user or role.

resource "aws_iam_policy" "s3_shared_bucket" {
  name        = "customer-s3-shared-bucket"
  path        = "/"
  description = "Access to shared bucket in other account"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:DeleteObject"
            ],
            "Resource": [
              "arn:aws:s3:::${var.bucket_name}",
              "arn:aws:s3:::${var.bucket_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:List*"
            ],
            "Resource": [
              "arn:aws:s3:::${var.bucket_name}",
              "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
}
EOF
}
