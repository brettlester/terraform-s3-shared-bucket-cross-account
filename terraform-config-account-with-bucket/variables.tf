# Bucket names are globally unique across the entire AWS cloud. You must define
# a globally unique bucket name in the bucket_name variable for this code sample
# to work.

variable "bucket_name" {
  type        = string
  description = "Name of the shared bucket"
}

variable "share_to_role_arns" {
  type        = list(string)
  description = "ARNs of the IAM roles in other AWS accounts which will have access to the shared bucket"
}
