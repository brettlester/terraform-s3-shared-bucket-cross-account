# terraform-s3-shared-bucket-cross-account
Terraform configurations to create an S3 bucket and share it between AWS accounts.

# Structure

There are two Terraform configurations, each in a separate directory:

* `terraform-config-account-with-bucket` contains the configuration for creating the S3 bucket. It also adds a bucket policy that permits the S3 bucket and its contents to be shared with the other account.

* `terraform-config-account-to-access-bucket` contains the configuration for the non-owner account to access the S3 bucket. It creates an IAM role, an IAM policy to allow access to the S3 bucket and attaches the IAM policy to the role.

These configurations should apply successfully with only changes to variable values in `terraform.tfvars`:

1. Change the `bucket_name` in both configurations to your desired S3 bucket name.

2. In the `terraform-config-account-with-bucket` configuration, change the value of `share_to_role_arns` to include the ARNs of any IAM roles in other AWS accounts that need to access the bucket.

# Order of `terraform apply` is important

You must apply the `terraform-config-account-to-access-bucket` configuration first. This is because it creates an IAM role that the `terraform-config-account-with-bucket` configuration references. The `terraform-config-account-with-bucket` configuration will fail when creating the bucket policy if you do not apply the configurations in the correct order.

In other words, you must create the IAM roles in the non bucket owner account before you can update the bucket policy to reference those IAM roles.

# Object permissions

By default S3 considers the owner of an object in an S3 bucket to be the account of the user or role that PUT it there. This can prevent the bucket owner account from being able to access objects that were PUT in the object by other accounts. To prevent this from happening, the non-owner account can specify an ACL that allows the bucket owner to have full control over the object.

For example:
```
aws s3 cp file.ext s3://bucketname --acl bucket-owner-full-control
```

The bucket policy prevents objects from being PUT unless the correct ACL is specified as shown above.

The permissions defined in the bucket policy and the non-owner account IAM policy are very permissive. You can adjust them as required, for example, if the non-owner account does not need to delete objects.

Did you spot an error or do you have a suggestion for improvement? Please submit a pull request. :)
