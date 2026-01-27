output "iam_user_name" {
  description = "Nom de l'utilisateur IAM créé"
  value       = aws_iam_user.app_user.name
}

output "iam_user_arn" {
  description = "ARN de l'utilisateur IAM créé"
  value       = aws_iam_user.app_user.arn
}

output "s3_bucket_name" {
  description = "Nom du bucket S3 créé"
  value       = aws_s3_bucket.app_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN du bucket S3"
  value       = aws_s3_bucket.app_bucket.arn
}

output "s3_bucket_region" {
  description = "Région du bucket S3"
  value       = aws_s3_bucket.app_bucket.region
}

output "index_html_key" {
  description = "Clé du fichier index.html dans S3"
  value       = aws_s3_object.index_html.key
}
