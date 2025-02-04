import logging
from logging.handlers import RotatingFileHandler
import os
from flask import Flask, send_from_directory, render_template
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from sqlalchemy import text
from flask_migrate import Migrate
from dotenv import load_dotenv
from datetime import timedelta
from config import Config
from utils.frontend_manager import download_and_extract_frontend

load_dotenv()
db = SQLAlchemy()

def create_app():
    """
    Creates and configures the Flask application.

    This function initializes the Flask app with necessary configurations, including
    enabling CORS, setting up JWT authentication, and registering blueprints for routes.

    Returns:
        Flask: The configured Flask application.
    """
    app = Flask(__name__, static_folder=None)  # Initialize without static folder
    CORS(app, resources={r"/*": {"origins": "*"}})
    app.config.from_object(Config)

    # Download frontend files
    with app.app_context():
        logging.info("Downloading frontend files...")
        if download_and_extract_frontend():
            logging.info("Frontend files downloaded successfully")
        else:
            logging.error("Failed to download frontend files")

    # Set up static file serving
    app.static_folder = app.config['FRONTEND_PATH']
    app.static_url_path = ''  # This ensures static files are served from the root

    # Register blueprints for both prefixed and unprefixed routes
    from app.routes.auth_routes import auth_bp
    from app.routes.product_routes import product_bp
    from app.routes.user_routes import user_bp
    from app.routes.health_routes import health_bp
    
    # Register routes without prefix
    app.register_blueprint(auth_bp)
    app.register_blueprint(product_bp)
    app.register_blueprint(user_bp)
    app.register_blueprint(health_bp)
    
    # Register routes with 'undefined' prefix
    app.register_blueprint(auth_bp, url_prefix='/undefined')
    app.register_blueprint(product_bp, url_prefix='/undefined')
    app.register_blueprint(user_bp, url_prefix='/undefined')
    app.register_blueprint(health_bp, url_prefix='/undefined')

    @app.route('/', defaults={'path': ''})
    @app.route('/<path:path>')
    def serve(path):
        if path != "" and os.path.exists(os.path.join(app.config['FRONTEND_PATH'], path)):
            return send_from_directory(app.config['FRONTEND_PATH'], path)
            
        # Read and modify index.html content
        with open(os.path.join(app.config['FRONTEND_PATH'], 'index.html'), 'r') as f:
            content = f.read()
            
        # Use empty string for backend URL to use relative paths
        backend_url = ""
        
        # Replace the placeholder with empty string
        content = content.replace('window.__RUNTIME_CONFIG__={BACKEND_URL:"{{BACKEND_URL}}"}', 
                                f'window.__RUNTIME_CONFIG__={{BACKEND_URL:"{backend_url}"}};')
        
        return content, 200, {'Content-Type': 'text/html'}

    db.init_app(app)

    with app.app_context():
        if app.config['SQLALCHEMY_DATABASE_URI'].startswith('sqlite'):
            db.session.execute(text('PRAGMA foreign_keys=ON'))

    JWTManager(app)

    return app


def setup_logging(app):
    """
    Set up logging to a file, creating the log file if it doesn't exist.
    Logs will rotate when they reach a certain size.
    """
    if not os.path.exists('logs'):
        os.mkdir('logs')

    log_file = 'logs/app.log'

    file_handler = RotatingFileHandler(log_file, maxBytes=1024 * 1024, backupCount=5)
    file_handler.setLevel(logging.INFO)

    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    file_handler.setFormatter(formatter)

    app.logger.addHandler(file_handler)
    app.logger.setLevel(logging.INFO)
