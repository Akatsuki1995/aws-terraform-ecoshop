

```markdown
# ☁️ Infrastructure AWS 3-Tiers avec Terraform

Ce projet automatise le déploiement d’une **infrastructure AWS complète et sécurisée** selon une architecture **3-Tiers** en utilisant **Terraform (Infrastructure as Code)**.  
Il a été réalisé dans le cadre du *Mastère Cybersécurité & Cloud Computing* à **l’École IPSSI**.

---

## 🧱 Vue d’ensemble de l’architecture

### 🔹 Objectif du projet
Mettre en place une architecture **Cloud AWS modulaire et évolutive** comprenant :
- **VPC (10.0.0.0/16)** — réseau isolé avec sous-réseaux publics et privés répartis sur 2 zones de disponibilité  
- **Public Tier** — Application Load Balancer (ALB) + Bastion Host  
- **Application Tier** — Auto Scaling Group (2 instances EC2) exécutant Apache sur le port 8080  
- **Database Tier** — Amazon RDS PostgreSQL (accès privé uniquement)  
- **Security Groups** — application stricte du principe du moindre privilège  
- **NAT Gateway / Internet Gateway** — contrôle du trafic sortant et entrant  

### 🗺️ Diagramme d’architecture
![AWS 3-Tier Architecture](diagrams/Untitled%20Diagram.drawio.png)

---

## 🧩 Structure du projet

```

aws-terraform-ecoshop/
│
├── envs/                     # Variables d'environnement
│   ├── dev.tfvars
│   └── prod.tfvars
│
├── modules/                  # Modules Terraform réutilisables
│   ├── alb/                  # Application Load Balancer
│   ├── compute/              # EC2, Auto Scaling Group, user_data
│   ├── network/              # VPC, sous-réseaux, routes, IGW, NAT
│   ├── rds/                  # Base de données PostgreSQL
│   └── security/             # Groupes de sécurité et règles associées
│
├── providers/                # Configuration des fournisseurs (AWS, etc.)
│
├── main.tf                   # Orchestration principale
├── variables.tf              # Variables globales
├── outputs.tf                # Sorties globales
├── providers.tf              # Définition du provider AWS
├── .gitignore
├── terraform-plan.txt
├── terraform.tfstate
├── terraform.tfstate.backup
└── README.md

````

---

## ⚙️ Procédure d’exécution Terraform

> Toutes les commandes doivent être lancées depuis la racine du projet.  
> Exemple avec l’environnement **`dev.tfvars`**.

### 1️⃣ **Initialisation**
Téléchargement des plugins et configuration du backend :
```bash
terraform init
````

### 2️⃣ **Validation**

Vérification de la syntaxe et des variables :

```bash
terraform validate
```

### 3️⃣ **Planification**

Prévisualisation des ressources AWS à créer :

```bash
terraform plan -var-file=envs/dev.tfvars -out=tfplan
```

### 4️⃣ **Déploiement**

Application du plan d’infrastructure :

```bash
terraform apply "tfplan"
```

✅ **Résultats attendus :**

* Nom DNS de l’ALB (pour tester via navigateur)
* IP publique du Bastion (accès SSH)
* Endpoint de la base de données PostgreSQL (accès privé)

### 5️⃣ **Vérification**

Tests de connectivité :

```bash
# Connexion SSH au Bastion
ssh -i ~/.ssh/terraform-key.pem ec2-user@<IP_PUBLIQUE_BASTION>

# Depuis le Bastion vers une instance privée
ssh -i ~/.ssh/terraform-key.pem ec2-user@<IP_PRIVEE_APP>

# Test HTTP local
curl http://<DNS_ALB>
```

---

## 🧹 **Destruction de l’infrastructure**

Pour supprimer l’ensemble des ressources AWS créées :

```bash
terraform destroy -var-file=envs/dev.tfvars
```

💡 Vérifiez toujours la liste des ressources avant de valider avec `yes`.

---

## 🧠 Compétences mises en œuvre

* Conception modulaire avec Terraform (réutilisabilité, scalabilité)
* Implémentation du principe de moindre privilège via les Security Groups
* Débogage des dépendances entre ressources Terraform
* Maîtrise des composants réseau AWS (VPC, Subnets, NAT, IGW, RDS)
* Documentation technique et schémas d’architecture avec LaTeX + Draw.io

---

## 👨‍💻 Auteur

**Mohamed Hakam Koubaa**
🎓 Mastère Cybersécurité & Cloud Computing — École IPSSI
📧 [hakamkoubaa@gmail.com](mailto:hakamkoubaa@gmail.com)
🔗 [LinkedIn](https://www.linkedin.com/in/hakam-koubaa) | [GitHub](https://github.com/Akatsuki1995)

---

## 🪪 Licence

Projet partagé sous **licence MIT**, à but éducatif et démonstratif.

```

---

Would you like me to generate a **bilingual version (🇫🇷/🇬🇧 side by side)** next — formatted as a single README.md sectioned by language (useful for GitHub presentation)?
```
