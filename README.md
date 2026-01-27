# Projet Terraform AWS avec CI/CD

Ce projet déploie automatiquement une infrastructure AWS en utilisant Terraform et un pipeline CI/CD (GitLab CI ou GitHub Actions).

## Table des matières
- [Prérequis](#prérequis)
- [Architecture](#architecture)
- [Configuration initiale](#configuration-initiale)
- [Utilisation locale](#utilisation-locale)
- [Configuration CI/CD](#configuration-cicd)
- [Ressources créées](#ressources-créées)
- [Troubleshooting](#troubleshooting)

## Prérequis

- Compte AWS avec accès administrateur
- Terraform >= 1.0 installé localement (pour tests)
- Compte GitLab ou GitHub
- Git installé sur votre machine

## Architecture

Ce projet crée les ressources AWS suivantes :
- **Utilisateur IAM** : `app-user-terraform` avec permissions S3
- **Bucket S3** : Stockage avec versioning activé
- **Fichier HTML** : Un fichier index.html uploadé sur S3

## Configuration initiale

### Créer un utilisateur IAM pour Terraform

Dans la console AWS :

1. Accédez à **IAM** → **Users** → **Create user**
2. Nom d'utilisateur : `terraform-cicd-user`
3. Cochez "Provide user access to the AWS Management Console" - **NON**
4. Attachez ces politiques :
   - `IAMFullAccess`
   - `AmazonS3FullAccess`
5. Créez des **Access Keys** (CLI access)
6. **IMPORTANT** : Notez ces valeurs (vous ne les reverrez plus !) :
   ```
   AWS_ACCESS_KEY_ID=AKIA...
   AWS_SECRET_ACCESS_KEY=...
   ```

### 2️⃣ Modifier le nom du bucket S3

Le nom du bucket S3 doit être **globalement unique** dans tout AWS.

Éditez le fichier `terraform.tfvars` :
```hcl
bucket_name = "votre-prenom-nom-bucket-2026"
```

**Exemple** : `jean-dupont-terraform-bucket-2026`

### Cloner et initialiser le projet

```bash
# Créer un nouveau repo sur GitLab/GitHub
# Ensuite :

git init
git add .
git commit -m "Initial commit - Terraform AWS project"
git remote add origin https://gitlab.com/votre-username/votre-repo.git
# OU pour GitHub :
# git remote add origin https://github.com/votre-username/votre-repo.git

git push -u origin main
```

## Utilisation locale

Pour tester en local avant de pousser sur Git :

```bash
# 1. Configurer les credentials AWS
export AWS_ACCESS_KEY_ID="votre_access_key"
export AWS_SECRET_ACCESS_KEY="votre_secret_key"
export AWS_DEFAULT_REGION="us-east-1"

# 2. Initialiser Terraform
terraform init

# 3. Valider la configuration
terraform validate

# 4. Voir le plan d'exécution
terraform plan

# 5. Appliquer les changements
terraform apply

# 6. Voir les outputs
terraform output

# 7. Détruire l'infrastructure (si nécessaire)
terraform destroy
```

## Configuration CI/CD

### Pour GitLab CI

1. Allez dans votre projet GitLab
2. **Settings** → **CI/CD** → **Variables**
3. Ajoutez ces variables (protégées et masquées) :
   - `AWS_ACCESS_KEY_ID` : Votre access key
   - `AWS_SECRET_ACCESS_KEY` : Votre secret key

Le fichier `.gitlab-ci.yml` est déjà configuré avec 3 stages :
- `validate` : Validation du code Terraform
- `plan` : Création du plan d'exécution
- `apply` : Application des changements (manuel par défaut)

### Pour GitHub Actions

1. Allez dans votre repo GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Cliquez sur **New repository secret**
4. Ajoutez ces secrets :
   - `AWS_ACCESS_KEY_ID` : Votre access key
   - `AWS_SECRET_ACCESS_KEY` : Votre secret key

Le fichier `.github/workflows/terraform.yml` est déjà configuré !

### 🎬 Déclencher le pipeline

Chaque fois que vous modifiez un fichier `.tf` et que vous le poussez :

```bash
# Modifier un fichier
nano main.tf

# Commiter et pousser
git add .
git commit -m "Update infrastructure"
git push origin main
```

Le pipeline s'exécutera automatiquement avec les 3 jobs :
1. ✅ **Terraform Init** : Initialisation
2. ✅ **Terraform Plan** : Planification
3. ✅ **Terraform Apply** : Déploiement (sur branche main)

## 📦 Ressources créées

Après un `terraform apply` réussi :

| Ressource | Nom | Description |
|-----------|-----|-------------|
| Utilisateur IAM | `app-user-terraform` | Utilisateur avec accès S3 |
| Bucket S3 | `votre-nom-unique-bucket-2026` | Stockage avec versioning |
| Fichier S3 | `index.html` | Page HTML personnalisée |

### Vérifier les ressources

```bash
# Lister les outputs
terraform output

# Voir l'utilisateur IAM créé
aws iam get-user --user-name app-user-terraform

# Lister les buckets S3
aws s3 ls

# Voir le contenu du bucket
aws s3 ls s3://votre-nom-unique-bucket-2026/
```

## 🔧 Troubleshooting

### Erreur : "Bucket name already exists"

**Solution** : Changez le nom du bucket dans `terraform.tfvars` pour un nom unique.

### Erreur : "Access Denied"

**Solution** : Vérifiez que :
- Les credentials AWS sont corrects
- L'utilisateur IAM a les bonnes permissions
- Les variables d'environnement sont bien configurées

### Erreur : "terraform.tfstate: permission denied"

**Solution** : Le fichier d'état Terraform est en lecture seule.
```bash
chmod 644 terraform.tfstate
```

### Le pipeline échoue sur GitLab/GitHub

**Solution** :
1. Vérifiez que les secrets AWS sont bien configurés
2. Consultez les logs du pipeline
3. Assurez-vous que le fichier `terraform.tfvars` a un bucket name unique

### Tester la connexion AWS

```bash
aws sts get-caller-identity
```

Cela doit retourner votre identité AWS.

## 📚 Commandes utiles

```bash
# Formater le code Terraform
terraform fmt

# Voir l'état actuel
terraform show

# Lister les ressources gérées
terraform state list

# Voir une ressource spécifique
terraform state show aws_s3_bucket.app_bucket

# Importer une ressource existante
terraform import aws_s3_bucket.app_bucket nom-du-bucket

# Refresh de l'état
terraform refresh

# Valider sans appliquer
terraform plan -out=tfplan

# Graphique des dépendances
terraform graph | dot -Tpng > graph.png
```

## 🎓 Prochaines étapes

Pour améliorer ce projet :

1. **Backend distant** : Stocker le state sur S3 avec DynamoDB pour le locking
2. **Modules** : Organiser le code en modules réutilisables
3. **Workspaces** : Gérer plusieurs environnements (dev, staging, prod)
4. **Secrets** : Utiliser AWS Secrets Manager pour les données sensibles
5. **Monitoring** : Ajouter CloudWatch pour surveiller les ressources

## 📝 Licence

Ce projet est à usage éducatif.

## Auteur

Créé pour le cours Terraform AWS.

---

**Date de création** : Janvier 2026  
**Version Terraform** : >= 1.0  
**Provider AWS** : ~> 5.0