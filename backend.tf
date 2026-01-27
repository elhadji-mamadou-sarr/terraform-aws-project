# Backend Configuration (Optionnel - à activer après première exécution locale)
# 
# Cette configuration stocke l'état Terraform sur S3 au lieu du fichier local
# Avantage : Collaboration en équipe, état partagé et sécurisé
#
# INSTRUCTIONS :
# 1. Commentez ce bloc pour la première exécution
# 2. Créez d'abord le bucket S3 manuellement ou via un autre projet
# 3. Décommentez ce bloc et lancez : terraform init -migrate-state

# terraform {
#   backend "s3" {
#     bucket         = "votre-nom-terraform-state-bucket"
#     key            = "terraform/state/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# Pour créer la table DynamoDB pour le locking :
# 
# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = "terraform-state-lock"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"
# 
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# 
#   tags = {
#     Name        = "Terraform State Lock Table"
#     Environment = "shared"
#   }
# }
