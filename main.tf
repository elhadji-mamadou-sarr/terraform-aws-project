terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Création d'un utilisateur IAM
resource "aws_iam_user" "app_user" {
  name = var.iam_user_name
  path = "/system/"

  tags = {
    Name        = var.iam_user_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Politique IAM pour l'utilisateur (lecture S3)
resource "aws_iam_user_policy" "app_user_policy" {
  name = "${var.iam_user_name}-policy"
  user = aws_iam_user.app_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app_bucket.arn,
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Création d'un bucket S3
resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Configuration du versioning pour le bucket
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Bloquer l'accès public par défaut
resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload du fichier index.html
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.app_bucket.id
  key          = "index.html"
  source       = "${path.module}/files/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/files/index.html")

  tags = {
    Name        = "index.html"
    Environment = var.environment
  }
}
