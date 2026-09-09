GroceryMate
🏆 GroceryMate E-Commerce Platform
Python OS Database GitHub Release Free

⭐ Star us on GitHub — it motivates us a lot!

📌 Table of Contents
Overview
Features
Screenshots & Demo
Prerequisites
Installation
Clone Repository
Configure PostgreSQL
Populate Database
Set Up Python Environment
Set Environment Variables
Start the Application
Usage
Contributing
License
🚀 Overview
GroceryMate is an application developed as part of the Masterschools program by Alejandro Roman Ibanez. It is a modern, full-featured e-commerce platform designed for seamless online grocery shopping. It provides an intuitive user interface and a secure backend, allowing users to browse products, manage their shopping basket, and complete purchases efficiently.

GroceryMate is a modern, full-featured e-commerce platform designed for seamless online grocery shopping. It provides an intuitive user interface and a secure backend, allowing users to browse products, manage their shopping basket, and complete purchases efficiently.

🛒 Features
🛡️ User Authentication: Secure registration, login, and session management.
🔒 Protected Routes: Access control for authenticated users.
🔎 Product Search & Filtering: Browse products, apply filters, and sort by category or price.
⭐ Favorites Management: Save preferred products.
🛍️ Shopping Basket: Add, view, modify, and remove items.
💳 Checkout Process:
Secure billing and shipping information handling.
Multiple payment options.
Automatic total price calculation.
📸 Screenshots & Demo
imagen imagen imagen imagen

 Home.mp4 
📋 Prerequisites
Ensure the following dependencies are installed before running the application:

🐍 Python (>=3.11)
🐘 PostgreSQL – Database for storing product and user information.
🛠️ Git – Version control system.
⚙️ Installation
🔹 Clone Repository
git clone --branch version2 https://github.com/AlejandroRomanIbanez/AWS_grocery.git && cd AWS_grocery
🔹 Configure PostgreSQL
Before creating the database user, you can choose a custom username and password to enhance security. Replace <your_secure_password> with a strong password of your choice in the following commands.

Create database and user:

psql -U postgres -c "CREATE DATABASE grocerymate_db;"
psql -U postgres -c "CREATE USER grocery_user WITH ENCRYPTED PASSWORD '<your_secure_password>';"  # Replace <your_secure_password> with a strong password of your choice
psql -U postgres -c "ALTER USER grocery_user WITH SUPERUSER;"
🔹 Populate Database
psql -U grocery_user -d grocerymate_db -f backend/app/sqlite_dump_clean.sql
Verify insertion:

psql -U grocery_user -d grocerymate_db -c "SELECT * FROM users;"
psql -U grocery_user -d grocerymate_db -c "SELECT * FROM products;"
🔹 Set Up Python Environment
Install dependencies in an activated virtual Enviroment:

cd backend
pip install -r requirements.txt
OR (if pip doesn't exist)

pip3 install -r requirements.txt
🔹 Set Environment Variables
Create a .env file:

touch .env  # macOS/Linux
ni .env -Force  # Windows
Generate a secure JWT key:

python3 -c "import secrets; print(secrets.token_hex(32))"
Update .env:

nano .env
Fill in the following information (make sure to replace the placeholders):

JWT_SECRET_KEY=<your_generated_key>
POSTGRES_USER=grocery_user
POSTGRES_PASSWORD=<your_password>
POSTGRES_DB=grocerymate_db
POSTGRES_HOST=localhost
POSTGRES_URI=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}
🔹 Start the Application
python3 run.py
📖 Usage
Access the application at http://localhost:5000
Register/Login to your account
Browse and search for products
Manage favorites and shopping basket
Proceed through the checkout process
🤝 Contributing
We welcome contributions! Please follow these steps:

Fork the repository.
Create a new feature branch (feature/your-feature).
Implement your changes and commit them.
Push your branch and create a pull request.
📜 License
This project is licensed under the MIT License.
