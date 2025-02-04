from flask import Flask, send_from_directory
from utils.frontend_manager import download_and_extract_frontend
from flask_cors import CORS  # Add CORS support
import os
from config import Config

def create_app(config_class=Config):
    app = Flask(__name__, 
                static_folder=config_class.STATIC_FOLDER,
                static_url_path='')
    app.config.from_object(config_class)
    CORS(app)  # Enable CORS
    
    # Register blueprints for API routes
    from routes.auth import auth_bp
    from routes.api import api_bp
    
    # Mount API routes at /api
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # Download frontend files on startup
    download_and_extract_frontend()
    
    # Serve frontend files - this should come after API routes
    @app.route('/', defaults={'path': ''})
    @app.route('/<path:path>')
    def serve(path):
        if path.startswith('api/'):
            return app.handle_http_exception(404)
        
        if path and os.path.exists(os.path.join(app.static_folder, path)):
            return send_from_directory(app.static_folder, path)
        return send_from_directory(app.static_folder, 'index.html')
    
    return app 