# TP Terraform — Déploiement AWS

Déploiement d'une application **Angular + Flask** sur AWS avec Terraform.
## Structure des fichiers

```
tp-terraform/
├── terraform.tf            # Version Terraform & providers
├── provider.tf             # Configuration AWS provider
├── variables.tf            # Déclaration des variables
├── terraform.tfvars        # Valeurs des variables
├── data.tf                 # Ressources existantes (VPC, IGW, AMI)
├── main.tf                 # Toutes les ressources AWS
├── outputs.tf              # Outputs (IPs)
├── frontend-user-data.sh   # Script d'installation Angular
├── backend-user-data.sh    # Script d'installation Flask
└── .gitignore
```

## Prérequis

- Terraform >= 1.0.0
- AWS CLI configuré (`aws configure`)
- Clé SSH générée :

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/tp-terraform-key
```

## Déploiement

```bash
# 1. Initialiser Terraform
terraform init

# 2. Vérifier le plan
terraform plan

# 3. Appliquer
terraform apply
```

## Accès

Après `terraform apply` :

```bash
# IP publique du frontend
terraform output frontend_public_ip

# IP privée du backend
terraform output backend_private_ip

# Ouvrir l'application
http://<frontend_public_ip>

# SSH frontend
ssh -i ~/.ssh/tp-terraform-key ec2-user@<frontend_public_ip>

# SSH backend (via frontend)
ssh -i ~/.ssh/tp-terraform-key -J ec2-user@<frontend_public_ip> ec2-user@<backend_private_ip>
```

## Destruction

```bash
terraform destroy
```
