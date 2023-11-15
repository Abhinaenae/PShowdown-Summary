terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
  #Configuration options
  region = "us-east-1"
  access_key = var.acc_key
  secret_key = var.sec_key
}

resource "aws_s3_bucket" "abhibucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "websitebucket"{
    bucket = aws_s3_bucket.abhibucket.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_public_access_block" "websitebucket" {
  bucket = aws_s3_bucket.abhibucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "websitebucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.websitebucket,
    aws_s3_bucket_public_access_block.websitebucket,
  ]

  bucket = aws_s3_bucket.abhibucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.abhibucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.abhibucket.id
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "image" {
    bucket = aws_s3_bucket.abhibucket.id
    key = "pfp.jpg"
    source = "pfp.jpg"
    acl = "public-read"
  }

resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.abhibucket.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }

    depends_on = [ aws_s3_bucket_acl.websitebucket ]
  } 
output "websiteendpoint" {
  value = aws_s3_bucket.abhibucket.website_endpoint
}
