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

# Désactiver le contrôle de propriété des objets (requis pour l'accès public)
resource "aws_s3_bucket_ownership_controls" "app_bucket_ownership" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configuration du versioning pour le bucket
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# DÉSACTIVER le blocage de l'accès public
resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Policy pour autoriser l'accès public en lecture
resource "aws_s3_bucket_policy" "app_bucket_policy" {
  bucket = aws_s3_bucket.app_bucket.id

  # S'assurer que le public access block est désactivé en premier
  depends_on = [aws_s3_bucket_public_access_block.app_bucket_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.app_bucket.arn}/*"
      }
    ]
  })
}

# Upload du fichier index.html avec ACL public
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.app_bucket.id
  key          = "index.html"
  source       = "${path.module}/files/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/files/index.html")
  acl          = "public-read"

  # S'assurer que les ownership controls sont configurés en premier
  depends_on = [aws_s3_bucket_ownership_controls.app_bucket_ownership]

  tags = {
    Name        = "index.html"
    Environment = var.environment
  }
}
