terraform {
  backend "s3" {
    encrypt = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  profile = "admin_Dorcas"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "infra-chi-bucket"
  force_destroy = true
}
  
resource "aws_kms_key" "terraform_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}
  
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


