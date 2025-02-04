import os
from datetime import timedelta
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class Config:
    # Database configuration
    SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(os.path.abspath(os.path.dirname(__file__)), "app", "local.db")
    if os.getenv("POSTGRES_URI"):
        SQLALCHEMY_DATABASE_URI = os.getenv("POSTGRES_URI")

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "default_dev_key")  # Default key for development
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=4)
    
    # Server port configuration
    PORT = int(os.getenv('PORT', 8080))
    
    # Frontend build directory (contains all static files)
    FRONTEND_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'frontend', 'build'))
    
    # GitHub release URL for frontend files
    FRONTEND_RELEASE_URL = os.getenv('FRONTEND_RELEASE_URL', 
        'https://github.com/AlejandroRomanIbanez/AWS_grocery/releases/tag/v1.0.0') 