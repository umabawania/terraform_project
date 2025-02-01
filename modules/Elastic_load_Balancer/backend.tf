terraform {
  backend "s3" {
    bucket         = var.s3_bucket
    key            = var.tfstate_path
    region         = var.region
    dynamodb_table = var.dynamodb_table
    encrypt        = true
  }
}