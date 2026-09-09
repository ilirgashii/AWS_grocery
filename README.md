# GroceryMate 🛒

**Fresh Code. Fresh Groceries. Always On**

A full-stack grocery e-commerce application with AWS cloud infrastructure, built with Python Flask backend, React frontend, and PostgreSQL database.

---

## 🚀 Choose Your Deployment Path

### 1️⃣ **Local Development** (Recommended for Learning)
Run GroceryMate locally on your computer:
- Python Flask backend
- PostgreSQL database (WSL/Linux)
- No AWS account needed
- Perfect for: Development, testing, learning

**[→ See Local Setup Guide](#run-locally-development)**

---

### 2️⃣ **AWS Cloud Deployment** (Production Ready)
Deploy to AWS with Infrastructure as Code:
- EC2 compute (Docker container)
- RDS PostgreSQL Multi-AZ
- S3 storage (avatars)
- CloudWatch Logs monitoring
- Fully automated with Terraform

**[→ See Infrastructure Guide](./infrastructure/README.md)**

---

## ✨ Application Features

### Frontend
- 🏪 Product catalog with categories
- 🛒 Shopping cart management
- 👤 User authentication (JWT)
- 📦 Order tracking
- ⭐ Product reviews & ratings
- 👨‍💼 Admin dashboard

### Backend
- 🔐 RESTful API with JWT authentication
- 📊 PostgreSQL database with SQLAlchemy ORM
- 🖼️ Avatar/image storage on AWS S3
- 📝 Comprehensive API documentation
- ✅ Error handling & validation

### Infrastructure
- ☁️ AWS VPC with public/private subnets (eu-central-1)
- 🐳 Docker containerization on EC2
- 🗄️ RDS PostgreSQL Multi-AZ
- 💾 S3 bucket for file storage
- 📊 CloudWatch Logs integration
- 🔐 IAM roles & security groups
- 📜 Infrastructure as Code (Terraform)

---

## 🏗️ Architecture

```
GroceryMate AWS Infrastructure (eu-central-1)
├── VPC (10.0.0.0/16)
│   ├── Public Subnet (10.0.1.0/24)
│   │   └── EC2 (t2.micro) → Docker Container → Flask App (port 5000)
│   └── Private Subnets (10.0.2.0/24, 10.0.3.0/24)
│       └── RDS PostgreSQL (Multi-AZ)
├── S3 Bucket (Avatar Storage)
├── CloudWatch Logs (/aws/ec2/grocerymate)
└── IAM Roles & Security Groups
```

**See full architecture:** [infrastructure/README.md](./infrastructure/README.md)

---

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- PostgreSQL 14+
- Docker (optional)
- AWS Account (for deployment)

### Run Locally (Development)

#### 1. Clone Repository
```bash
git clone https://github.com/ilirgashii/AWS_grocery.git
cd AWS_grocery
```

#### 2. Setup PostgreSQL (WSL/Linux)
```bash
sudo service postgresql start
sudo -u postgres psql

# Inside PostgreSQL:
CREATE USER dbadmin WITH PASSWORD 'admin123';
CREATE DATABASE grocerydb OWNER dbadmin;
GRANT ALL PRIVILEGES ON DATABASE grocerydb TO dbadmin;
\q
```

#### 3. Initialize Database Schema
```bash
cd backend
PGPASSWORD='admin123' psql -U dbadmin -d grocerydb -h localhost -f app/sqlite_dump_clean.sql
```

#### 4. Setup Python Environment
```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### 5. Configure Environment
```bash
cat > .env << EOF
POSTGRES_HOST=localhost
POSTGRES_USER=dbadmin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=grocerydb
POSTGRES_URI=postgresql://dbadmin:admin123@localhost:5432/grocerydb
JWT_SECRET_KEY=your-secret-key-here
USE_S3_STORAGE=false
EOF
```

#### 6. Run Application
```bash
python app.py
```

**App running:** http://localhost:5000

---

### Deploy to AWS (Production)

See [infrastructure/README.md](./infrastructure/README.md) for complete deployment guide.

**Quick Deploy:**
```bash
cd infrastructure

# Configure AWS credentials
aws sso login --profile default

# Deploy infrastructure
terraform init
terraform plan
terraform apply -auto-approve
```

**App will be running at:** `http://<EC2-PUBLIC-IP>:5000`

---

## 📁 Project Structure

```
AWS_grocery/
├── backend/
│   ├── app/
│   │   ├── routes/              # API endpoints
│   │   ├── models.py            # Database models
│   │   ├── auth_controller.py   # Authentication
│   │   └── sqlite_dump_clean.sql # Database schema
│   ├── requirements.txt          # Python dependencies
│   ├── app.py                    # Flask entry point
│   └── Dockerfile                # Container image
│
├── infrastructure/               # Terraform IaC
│   ├── main.tf                   # EC2, RDS, S3, IAM
│   ├── vpc.tf                    # VPC, Subnets, IGW
│   ├── deploy.tf                 # Application deployment
│   ├── cloudwatch.tf             # CloudWatch logs setup
│   ├── variables.tf              # Input variables
│   ├── outputs.tf                # Output values
│   ├── terraform.tfvars          # Secret values (git-ignored)
│   ├── .gitignore                # Protect secrets & state
│   └── README.md                 # Deployment guide
│
└── README.md                      # This file
```

---

## 🔐 Security Features

- ✅ JWT authentication for API
- ✅ Custom VPC with public/private subnets
- ✅ RDS in private subnet (no internet access)
- ✅ Security groups restrict traffic
- ✅ S3 bucket with public access blocked
- ✅ IAM roles (no hardcoded credentials)
- ✅ CloudWatch logs for monitoring
- ✅ Environment variables for secrets
- ✅ .gitignore protects sensitive files

---

## 📊 Tech Stack

### Frontend
- React
- JavaScript/JSX
- CSS/Bootstrap

### Backend
- Python 3.11
- Flask (web framework)
- SQLAlchemy (ORM)
- PyJWT (authentication)

### Database
- PostgreSQL 16
- AWS RDS (managed)

### Infrastructure
- AWS VPC
- AWS EC2 (t2.micro)
- AWS RDS (Multi-AZ)
- AWS S3
- AWS CloudWatch Logs
- Docker
- Terraform

---

## 💰 Cost Estimation

**When Running (24/7):**
```
EC2 (t2.micro):      ~$9.20/month
RDS (db.t3.micro):   ~$12.41/month
S3 Storage:          ~$0.05/month
CloudWatch Logs:     ~$0.05/month
Data Transfer:       ~$1-2/month
─────────────────────────────────
TOTAL:               ~$23-25/month
```

**Note:** Free tier (first 12 months) covers most of this! 🎉

---

## 🧪 Testing

### API Tests
```bash
# Get all products
curl http://localhost:5000/api/products/all_products

# Register user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"Test123!"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

### View CloudWatch Logs (AWS Deployment)
```bash
# Live logs
aws logs tail /aws/ec2/grocerymate --follow --region eu-central-1

# Last 100 events
aws logs tail /aws/ec2/grocerymate --max-items 100 --region eu-central-1
```

---

## 🐛 Troubleshooting

### Local Issues

**"Connection refused" - PostgreSQL**
```bash
# Start PostgreSQL
sudo service postgresql start
sudo service postgresql status
```

**"ModuleNotFoundError: No module named 'flask'"**
```bash
# Activate venv
source venv/bin/activate
# Re-install
pip install -r requirements.txt
```

**Database schema not found**
```bash
# Re-initialize schema
PGPASSWORD='admin123' psql -U dbadmin -d grocerydb -h localhost -f app/sqlite_dump_clean.sql
```

### AWS Deployment Issues

See [infrastructure/README.md - Troubleshooting](./infrastructure/README.md#troubleshooting)

---

## 📚 Documentation

- **Infrastructure:** [infrastructure/README.md](./infrastructure/README.md)
- **API Documentation:** See Flask endpoints in `backend/app/routes/`
- **Database Schema:** `backend/app/sqlite_dump_clean.sql`

---

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

MIT License - See LICENSE file for details

---

## 👤 Author

**Ilir Gashi**
- GitHub: [@ilirgashii](https://github.com/ilirgashii)
- Email: ilirgashi099@gmail.com

---
