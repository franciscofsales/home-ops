terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "1.5.3"
    }
  }
}

resource "minio_s3_bucket" "bucket" {
  bucket   = var.bucket_name
  acl      = "private"
}

resource "minio_iam_user" "user" {
  name          = var.bucket_name
  force_destroy = true
}

resource "minio_iam_policy" "rw_policy" {
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "user_rw" {
  user_name   = minio_iam_user.user.id
  policy_name = minio_iam_policy.rw_policy.id
}