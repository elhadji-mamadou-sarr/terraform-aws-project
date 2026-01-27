variable "aws_region" {
  description = "Région AWS où déployer les ressources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "iam_user_name" {
  description = "Nom de l'utilisateur IAM à créer"
  type        = string
  default     = "app-user-terraform"
}

variable "bucket_name" {
  description = "Nom du bucket S3 (doit être globalement unique)"
  type        = string
  # Vous devez modifier ce nom pour qu'il soit unique
  # Format recommandé: votreprenom-votrenom-bucket-YYYY
}
