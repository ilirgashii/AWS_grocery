# GroceryMate AWS Infrastructure (Terraform)

**Infrastructure as Code for AWS Deployment**

Complete Terraform configuration for deploying GroceryMate on AWS (eu-central-1 region).

---

## 📋 Table of Contents

1. [Architecture](#architecture)
2. [Prerequisites](#prerequisites)
3. [Deployment](#deployment)
4. [CloudWatch Logs](#cloudwatch-logs)
5. [File Structure](#file-structure)
6. [Security](#security)
7. [Cost Management](#cost-management)
8. [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture

### Infrastructure Overview

```
AWS Cloud (eu-central-1)
├── VPC (10.0.0.0/16)
│   ├── Public Subnet (10.0.1.0/24) - AZ: eu-central-1a
│   │   ├── EC2 Instance (t2.micro)
│   │   │   └── Docker Container
│   │   │       └── Flask App (Port 5000)
│   │   └── Internet Gateway
│   │
│   └── Private Subnets (10.0.2.0/24, 10.0.3.0/24) - AZ: 1a, 1b
│       └── RDS PostgreSQL (Multi-AZ)
│
├── S3 Bucket (Avatars Storage)
├── CloudWatch Logs (/aws/ec2/grocerymate)
└── IAM Roles & Security Groups
```

### Components

| Component | Type | Tier | Purpose |
|-----------|------|------|---------|
| EC2 | Compute | Public | Run Flask app in Docker |
| RDS PostgreSQL | Database | Private | Store application data |
| S3 | Storage | Public | Store user avatars |
| CloudWatch | Monitoring | Managed | Real-time application logs |
| VPC | Network | Managed | Isolated network environment |
| Security Groups | Network | Managed | Restrict traffic |
| IAM Roles | Access | Managed | Grant permissions |

---

## 📋 Prerequisites

### AWS Account
- ✅ Active AWS account
- ✅ Sufficient permissions (EC2, RDS, S3, CloudWatch, IAM)

### Local Tools
- ✅ Terraform 1.0+ ([install](https://www.terraform.io/downloads))
- ✅ AWS CLI v2 ([install](https://aws.amazon.com/cli/))
- ✅ SSH key pair (`~/.ssh/grocery-ec2-key`)

### AWS Credentials
```bash
# Configure AWS CLI with SSO
aws sso login --profile default

# Or configure with access keys
aws configure
```

**Verify Access:**
```bash
aws sts get-caller-identity
```

Should output:
```json
{
    "UserId": "...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::..."
}
```

---

## 🚀 Deployment

### Step 1: Initialize Terraform

```bash
cd infrastructure

terraform init
```

**What it does:**
- Downloads AWS provider plugins
- Creates `.terraform/` directory
- Initializes state management

### Step 2: Validate Configuration

```bash
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

### Step 3: Preview Changes

```bash
terraform plan
```

**Expected output:**
```
Plan: 25 to add, 0 to change, 0 destroy.

Changes to Outputs:
  + ec2_public_ip  = (known after apply)
  + rds_endpoint   = (known after apply)
  + s3_bucket_name = "..."
```

### Step 4: Deploy to AWS

```bash
terraform apply -auto-approve
```

**What it creates:**
1. VPC & Subnets
2. Internet Gateway & Route Tables
3. Security Groups (EC2 + RDS)
4. EC2 Instance (t2.micro)
5. RDS PostgreSQL Instance (Multi-AZ)
6. S3 Bucket (Avatars)
7. CloudWatch Log Group
8. IAM Roles & Policies

**Deployment Time:** 5-10 minutes

### Step 5: Verify Deployment

```bash
terraform output
```

**Get outputs:**
```
ec2_public_ip = "52.29.120.161"
rds_endpoint = "app-grocery-db.*.amazonaws.com:5432"
s3_bucket_name = "grocerymate-avatars-test-ig"
cloudwatch_log_group_name = "/aws/ec2/grocerymate"
```

### Step 6: Test Application

```bash
# Test API
curl http://<EC2-PUBLIC-IP>:5000/api/products/all_products

# Should return JSON with products
```

---

## 📊 CloudWatch Logs

### Overview

All Flask application logs are automatically sent to CloudWatch Logs via Docker's `awslogs` driver.

```
Flask App (Docker)
    ↓
CloudWatch Logs Driver (--log-driver awslogs)
    ↓
AWS CloudWatch Logs Service
    ↓
Log Group: /aws/ec2/grocerymate (7-day retention)
```

### View Logs

#### Option 1: AWS Console

```
1. AWS Console → CloudWatch → Log Groups
2. Search: /aws/ec2/grocerymate
3. Click log group → click log stream
4. See live Flask logs
```

#### Option 2: AWS CLI

**Live tail (follow logs):**
```bash
aws logs tail /aws/ec2/grocerymate --follow --region eu-central-1
```

**Last 100 events:**
```bash
aws logs tail /aws/ec2/grocerymate --max-items 100 --region eu-central-1
```

**Search for errors:**
```bash
aws logs filter-log-events \
  --log-group-name /aws/ec2/grocerymate \
  --filter-pattern "ERROR" \
  --region eu-central-1
```

### Log Output Example

```
2026-09-07T19:34:24 Using Database: postgresql://dbadmin:***@app-grocery-db.*.rds.amazonaws.com:5432/grocerydb
2026-09-07T19:34:24 Running on AWS RDS (Production)
2026-09-07T19:34:24 Frontend build downloaded and extracted successfully
2026-09-07T19:34:24 * Serving Flask app 'app'
2026-09-07T19:34:24 * Debug mode: on
2026-09-07T19:34:24 * Running on http://0.0.0.0:5000
2026-09-07T19:36:53 INFO in product_controller: Fetched all products.
2026-09-07T19:36:53 88.130.53.250 - - "GET /api/products/all_products HTTP/1.1" 200 -
```

### Retention & Cost

- **Retention:** 7 days (configurable)
- **Cost:** ~$0.05/month for typical usage
- **Searchable:** CloudWatch Logs Insights queries

---

## 📁 File Structure

```
infrastructure/
├── main.tf                          # EC2, RDS, S3, Outputs
├── vpc.tf                           # VPC, Subnets, IGW, Route Tables
├── deploy.tf                        # Deployment provisioners + CloudWatch
├── cloudwatch.tf                    # CloudWatch Log Group + IAM Policy (Week 9)
├── variables.tf                     # Input variables (db_username, password, etc)
├── terraform.tfvars                 # Secret values (git-ignored) ⚠️
├── terraform.tfstate                # State file (git-ignored) ⚠️
├── .gitignore                       # Protect secrets & state files
└── README.md                        # This file
```

### File Purposes

| File | Purpose |
|------|---------|
| `main.tf` | EC2 instance, RDS database, S3 bucket, IAM roles, outputs |
| `vpc.tf` | VPC networking: subnets, internet gateway, route tables |
| `deploy.tf` | Automated application deployment via provisioners |
| `cloudwatch.tf` | CloudWatch Logs integration (Week 9 update) |
| `variables.tf` | Input variables (database credentials, key paths) |
| `terraform.tfvars` | Secret values (passwords, keys) - NEVER commit! |
| `.gitignore` | Protect `.tfstate`, `*.tfvars`, `*.pem` from Git |

---

## 🔐 Security

### Network Security

- ✅ **Custom VPC** - Isolated network (10.0.0.0/16)
- ✅ **Public/Private Subnets** - Separate tiers
- ✅ **RDS in Private** - No direct internet access
- ✅ **Security Groups** - Restrict inbound traffic
  - EC2 allows: SSH(22), HTTP(80), App(5000)
  - RDS allows: PostgreSQL(5432) from EC2 only

### Application Security

- ✅ **JWT Authentication** - API requests require tokens
- ✅ **Environment Variables** - Secrets not in code
- ✅ **IAM Roles** - EC2 has role-based permissions (no hardcoded keys)
- ✅ **No Public RDS** - `publicly_accessible = false`

### Secrets Management

- ✅ **Variables marked sensitive** - Hidden from output
- ✅ **terraform.tfvars git-ignored** - Credentials never committed
- ✅ **SSH keys git-ignored** - Private keys protected
- ✅ **.tfstate git-ignored** - State file with all secrets protected

### Best Practices

1. **Never commit secrets:**
   ```bash
   # Check .gitignore
   cat .gitignore
   # Should exclude: *.tfvars, .tfstate, *.pem
   ```

2. **Use AWS SSO for credentials** (more secure than access keys)
   ```bash
   aws sso login --profile default
   ```

3. **Review terraform plan before apply:**
   ```bash
   terraform plan
   # Read output carefully, especially RDS password fields
   ```

4. **Store sensitive values in environment variables:**
   ```bash
   export TF_VAR_db_password="secure-password"
   export TF_VAR_jwt_secret_key="secret-key"
   ```

---

## 💰 Cost Management

### Estimated Monthly Costs

```
EC2 (t2.micro):         $9.20
RDS (db.t3.micro):      $12.41
RDS Storage (20GB):     $0.23
S3 Storage (2GB):       $0.05
CloudWatch Logs:        $0.05
Data Transfer:          $1-2
─────────────────────────────
TOTAL:                  $23-25/month
```

### Free Tier (First 12 Months)

If you're a new AWS account:
- EC2: 750 hours/month free
- RDS: 750 hours/month + 20GB storage free
- S3: 5GB free first year

**Your cost: $0 for 12 months!** 🎉

### Cost Optimization Tips

1. **Use t2.micro** - Free tier eligible
2. **Turn off when not needed:**
   ```bash
   # Stop EC2 (not delete)
   aws ec2 stop-instances --instance-ids i-xxxxx --region eu-central-1
   ```

3. **Clean up after testing:**
   ```bash
   # Destroy all resources
   terraform destroy -auto-approve
   # Removes: EC2, RDS, S3, VPC, etc.
   ```

4. **Monitor spending:**
   ```
   AWS Console → Billing → Bills
   Set up CloudWatch Alarms for budget exceeded
   ```

---

## 🧹 Cleanup

### Destroy Infrastructure

```bash
cd infrastructure

# Preview what will be deleted
terraform plan -destroy

# Destroy all resources
terraform destroy -auto-approve
```

**What gets deleted:**
- ✅ EC2 instance
- ✅ RDS database
- ✅ S3 bucket
- ✅ VPC, subnets, security groups
- ✅ CloudWatch logs
- ✅ IAM roles

**What stays:**
- ✅ Terraform code (can re-deploy anytime)
- ✅ GitHub repository
- ✅ Local backend code

### State File Cleanup

```bash
# After destroy, state file is empty
# You can delete local copies (but git-ignored anyway)
rm terraform.tfstate terraform.tfstate.backup
```

---

## 🐛 Troubleshooting

### Terraform Issues

**Error: "region is required"**
```
Solution: Check provider block in main.tf
provider "aws" {
  region = "eu-central-1"  # Must be set
}
```

**Error: "The image id does not exist"**
```
Solution: AMI ID is region-specific
For eu-central-1: ami-0f2f6d6f49dbe9fd1
Run: aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*" --region eu-central-1
```

**Error: "terraform.tfstate is locked"**
```
Solution: Another terraform process is running
Kill: pkill -f terraform
Or wait for other operation to complete
```

### Deployment Issues

**SSH: "Permission denied (publickey)"**
```bash
# Check SSH key exists
ls -la ~/.ssh/grocery-ec2-key

# Check permissions (must be 600)
chmod 600 ~/.ssh/grocery-ec2-key

# Test connection
ssh -i ~/.ssh/grocery-ec2-key ec2-user@<EC2-IP>
```

**Docker container not starting**
```bash
# SSH to EC2
ssh -i ~/.ssh/grocery-ec2-key ec2-user@<EC2-IP>

# Check Docker logs
docker logs grocerymate

# Check container status
docker ps -a
```

**RDS connection refused**
```bash
# Check RDS security group allows EC2
aws ec2 describe-security-groups --group-ids sg-xxxxx --region eu-central-1

# Should show inbound rule: PostgreSQL (5432) from EC2 security group
```

### CloudWatch Logs Issues

**No logs appearing**
```bash
# SSH to EC2
ssh -i ~/.ssh/grocery-ec2-key ec2-user@<EC2-IP>

# Check CloudWatch logs driver is running
docker logs -f grocerymate

# Check EC2 has CloudWatch IAM permissions
aws iam get-role-policy --role-name grocery-ec2-role --policy-name cloudwatch-logs-policy
```

**"AccessDeniedException: not authorized to perform: logs:FilterLogEvents"**
```
Solution: EC2 IAM role missing CloudWatch logs policy
Fix: Add aws_iam_role_policy "cloudwatch_logs_policy" (already in cloudwatch.tf)
Re-deploy: terraform apply
```

---

## 📚 Advanced Topics

### Terraform State Management

**Local State (Current Setup)**
```bash
# State stored locally in terraform.tfstate
# ⚠️ Git-ignored, never committed
ls -la terraform.tfstate
```

**Remote State (Recommended for Teams)**
```terraform
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "grocerymate/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}
```

### Scaling Up

**Change instance type (t2.micro → t2.small):**
```terraform
resource "aws_instance" "app_server" {
  instance_type = "t2.small"  # Change this
}
```

```bash
terraform plan
terraform apply
```

**Add RDS read replica:**
```terraform
resource "aws_db_instance" "app_db_read_replica" {
  replicate_source_db = aws_db_instance.app_db.identifier
  instance_class      = "db.t3.micro"
}
```

---

## 🔄 Deployment Workflow (Week 9)

```
1. Configure AWS credentials
   └─ aws sso login --profile default

2. Initialize Terraform
   └─ terraform init

3. Validate configuration
   └─ terraform validate

4. Review planned changes
   └─ terraform plan

5. Deploy infrastructure
   └─ terraform apply -auto-approve
   (Creates 25 resources in 5-10 min)

6. Get outputs
   └─ terraform output
   (EC2 IP, RDS endpoint, S3 name, CloudWatch logs)

7. Test application
   └─ curl http://<EC2-IP>:5000/api/products/all_products

8. View CloudWatch logs
   └─ aws logs tail /aws/ec2/grocerymate --follow

9. When done, cleanup
   └─ terraform destroy -auto-approve
```

---

## 📞 Support

### Get Help

1. **Terraform Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs
2. **AWS Docs:** https://docs.aws.amazon.com/
3. **CloudWatch Logs:** https://docs.aws.amazon.com/cloudwatch/latest/logs/
4. **GitHub Issues:** Create issue in repository

### Contact

- **Author:** Ilir Gashi
- **Email:** ilirg@example.com
- **GitHub:** @ilirgashii

---

## ✅ Checklist

Before deployment:
- [ ] AWS account created
- [ ] AWS credentials configured (aws sso login)
- [ ] Terraform installed (terraform --version)
- [ ] SSH key pair created (~/.ssh/grocery-ec2-key)
- [ ] Docker installed (for local testing)

After deployment:
- [ ] terraform output shows EC2 IP, RDS endpoint, S3 name
- [ ] curl test returns product JSON
- [ ] SSH to EC2 succeeds
- [ ] docker ps shows running container
- [ ] CloudWatch logs appear

After testing:
- [ ] terraform destroy completed
- [ ] AWS resources cleaned up
- [ ] GitHub code saved
- [ ] Screenshots/documentation saved

---



Made with ❤️ for Infrastructure as Code learning
