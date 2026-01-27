#!/bin/bash

# Script de démarrage rapide pour le projet Terraform AWS
# Usage: bash quick-start.sh

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Projet Terraform AWS - Quick Start       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Fonction pour afficher les étapes
print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Vérifier si Terraform est installé
echo -e "${BLUE}[1/7]${NC} Vérification de Terraform..."
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json | grep -o '"version":"[^"]*' | cut -d'"' -f4)
    print_step "Terraform $TERRAFORM_VERSION installé"
else
    print_error "Terraform n'est pas installé"
    echo "Installation recommandée :"
    echo "  macOS: brew install terraform"
    echo "  Ubuntu: https://developer.hashicorp.com/terraform/install"
    exit 1
fi

# Vérifier si AWS CLI est installé
echo -e "${BLUE}[2/7]${NC} Vérification d'AWS CLI..."
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version | cut -d' ' -f1 | cut -d'/' -f2)
    print_step "AWS CLI $AWS_VERSION installé"
else
    print_warning "AWS CLI n'est pas installé (recommandé mais optionnel)"
    echo "Installation : https://aws.amazon.com/cli/"
fi

# Vérifier les credentials AWS
echo -e "${BLUE}[3/7]${NC} Vérification des credentials AWS..."
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    print_warning "Credentials AWS non configurés en variables d'environnement"
    echo ""
    echo "Pour configurer :"
    echo "  export AWS_ACCESS_KEY_ID='AKIA...'"
    echo "  export AWS_SECRET_ACCESS_KEY='...'"
    echo "  export AWS_DEFAULT_REGION='us-east-1'"
    echo ""
    read -p "Voulez-vous les configurer maintenant ? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "AWS_ACCESS_KEY_ID: " access_key
        read -p "AWS_SECRET_ACCESS_KEY: " secret_key
        export AWS_ACCESS_KEY_ID="$access_key"
        export AWS_SECRET_ACCESS_KEY="$secret_key"
        export AWS_DEFAULT_REGION="us-east-1"
        print_step "Credentials configurés pour cette session"
    else
        print_warning "Continuez mais vous devrez configurer les credentials manuellement"
    fi
else
    # Tester la connexion AWS
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        print_step "Credentials AWS valides (Account: $ACCOUNT_ID)"
    else
        print_error "Credentials AWS invalides"
        exit 1
    fi
fi

# Vérifier le fichier terraform.tfvars
echo -e "${BLUE}[4/7]${NC} Vérification du fichier terraform.tfvars..."
if grep -q "votre-nom-unique-bucket-2026" terraform.tfvars 2>/dev/null; then
    print_warning "Le nom du bucket par défaut n'a pas été modifié !"
    echo ""
    echo "⚠️  IMPORTANT : Vous devez modifier le bucket_name dans terraform.tfvars"
    echo "   Il doit être GLOBALEMENT UNIQUE dans tout AWS"
    echo ""
    read -p "Voulez-vous le modifier maintenant ? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Entrez un nom de bucket unique (ex: jean-dupont-bucket-2026): " bucket_name
        sed -i.bak "s/votre-nom-unique-bucket-2026/$bucket_name/" terraform.tfvars
        print_step "Bucket name modifié : $bucket_name"
    else
        print_error "Vous devez modifier le bucket_name avant de continuer"
        echo "Éditez le fichier : nano terraform.tfvars"
        exit 1
    fi
else
    print_step "terraform.tfvars configuré"
fi

# Initialiser Terraform
echo -e "${BLUE}[5/7]${NC} Initialisation de Terraform..."
if terraform init > /dev/null 2>&1; then
    print_step "Terraform initialisé avec succès"
else
    print_error "Échec de l'initialisation Terraform"
    terraform init
    exit 1
fi

# Valider la configuration
echo -e "${BLUE}[6/7]${NC} Validation de la configuration..."
if terraform validate > /dev/null 2>&1; then
    print_step "Configuration Terraform valide"
else
    print_error "Erreur de validation Terraform"
    terraform validate
    exit 1
fi

# Créer le plan
echo -e "${BLUE}[7/7]${NC} Création du plan d'exécution..."
if terraform plan -out=tfplan > /dev/null 2>&1; then
    print_step "Plan créé avec succès"
else
    print_error "Échec de la création du plan"
    terraform plan
    exit 1
fi

# Résumé final
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Configuration terminée            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Prochaines étapes :${NC}"
echo ""
echo "  1. Vérifier le plan :"
echo -e "     ${YELLOW}terraform show tfplan${NC}"
echo ""
echo "  2. Appliquer les changements :"
echo -e "     ${YELLOW}terraform apply tfplan${NC}"
echo ""
echo "  3. Voir les outputs :"
echo -e "     ${YELLOW}terraform output${NC}"
echo ""
echo "  4. Détruire les ressources (après démo) :"
echo -e "     ${YELLOW}terraform destroy${NC}"
echo ""
echo -e "${BLUE}Pour le CI/CD :${NC}"
echo "  1. Créer un repo sur GitLab ou GitHub"
echo "  2. Ajouter les secrets AWS (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)"
echo "  3. Pousser le code : git push origin main"
echo "  4. Le pipeline s'exécutera automatiquement !"
echo ""
echo -e "${GREEN}Bonne chance ! 🚀${NC}"
