provider "aws" {
  region = "us-east-1"
}
variable "code_commit_repo" {}

resource "aws_s3_bucket" "pipline_artifacts" {
  bucket = "codepipeline-us-east-1-1234-batch5-tf"
  acl    = "private"
}