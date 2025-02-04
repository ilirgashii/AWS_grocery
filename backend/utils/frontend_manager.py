import os
import requests
import zipfile
from flask import current_app
import shutil
import logging
import json

logger = logging.getLogger(__name__)

def download_and_extract_frontend():
    """Download frontend files from GitHub release and extract them"""
    
    try:
        # Parse the release URL to get owner and repo
        release_url = current_app.config['FRONTEND_RELEASE_URL']
        parts = release_url.split('/')
        owner_idx = parts.index('github.com') + 1
        owner = parts[owner_idx]
        repo = parts[owner_idx + 1]
        tag = parts[-1]
        
        # Get release info from GitHub API
        api_url = f"https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}"
        logger.info(f"Fetching release info from: {api_url}")
        
        response = requests.get(api_url)
        if response.status_code != 200:
            logger.error(f"Failed to get release info: {response.status_code}")
            return False
            
        release_data = response.json()
        logger.info(f"Release data: {json.dumps(release_data, indent=2)}")
        
        # Find the frontend_build.zip asset
        frontend_asset = None
        logger.info(f"Available assets: {json.dumps([asset['name'] for asset in release_data['assets']], indent=2)}")
        for asset in release_data['assets']:
            if asset['name'] == 'frontend_build.zip':
                frontend_asset = asset
                break
                
        if not frontend_asset:
            logger.error("frontend_build.zip not found in release assets")
            return False
            
        # Create frontend directory if it doesn't exist
        os.makedirs(current_app.config['FRONTEND_PATH'], exist_ok=True)
        
        # Download the zip file
        logger.info(f"Downloading frontend from: {frontend_asset['browser_download_url']}")
        headers = {
            'Accept': 'application/octet-stream',
            'User-Agent': 'AWS_grocery_app'
        }
        response = requests.get(frontend_asset['browser_download_url'], headers=headers)
        
        if response.status_code == 200:
            zip_path = os.path.join(current_app.config['FRONTEND_PATH'], 'frontend_build.zip')
            
            # Save the zip file
            with open(zip_path, 'wb') as f:
                f.write(response.content)
            
            # Clear existing files
            for item in os.listdir(current_app.config['FRONTEND_PATH']):
                if item != 'frontend_build.zip':
                    item_path = os.path.join(current_app.config['FRONTEND_PATH'], item)
                    if os.path.isfile(item_path):
                        os.remove(item_path)
                    elif os.path.isdir(item_path):
                        shutil.rmtree(item_path)
            
            # Create a temporary directory for extraction
            temp_dir = os.path.join(current_app.config['FRONTEND_PATH'], 'temp')
            os.makedirs(temp_dir, exist_ok=True)
            
            # Extract the zip file to temp directory
            logger.info(f"Extracting frontend files to temp directory")
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                # Log the contents of the zip file
                logger.info(f"Zip contents: {json.dumps(zip_ref.namelist(), indent=2)}")
                zip_ref.extractall(temp_dir)
            
            # Find the release_artifacts directory
            artifacts_dir = os.path.join(temp_dir, 'release_artifacts')
            if not os.path.exists(artifacts_dir):
                logger.error("Could not find release_artifacts directory")
                shutil.rmtree(temp_dir)
                os.remove(zip_path)
                return False
            
            # Move files from release_artifacts directory to frontend path
            logger.info(f"Moving files from {artifacts_dir} to {current_app.config['FRONTEND_PATH']}")
            
            # First, move all root files
            root_files = ['index.html', 'favicon.ico', 'manifest.json', 'logo192.png', 'logo512.png', 'robots.txt', 'asset-manifest.json']
            for file in root_files:
                src = os.path.join(artifacts_dir, file)
                if os.path.exists(src):
                    shutil.copy2(src, current_app.config['FRONTEND_PATH'])
            
            # Then move the static directory
            static_src = os.path.join(artifacts_dir, 'static')
            static_dst = os.path.join(current_app.config['FRONTEND_PATH'], 'static')
            if os.path.exists(static_dst):
                shutil.rmtree(static_dst)
            if os.path.exists(static_src):
                shutil.copytree(static_src, static_dst)
            
            # Clean up
            shutil.rmtree(temp_dir)
            os.remove(zip_path)
            
            # Verify the files were copied correctly
            logger.info("Verifying copied files:")
            for root, dirs, files in os.walk(current_app.config['FRONTEND_PATH']):
                logger.info(f"Directory: {root}")
                logger.info(f"Files: {files}")
            
            logger.info("Frontend files successfully downloaded and extracted")
            return True
            
        logger.error(f"Failed to download frontend: {response.status_code}")
        return False
        
    except Exception as e:
        logger.error(f"Error downloading frontend: {str(e)}")
        import traceback
        logger.error(traceback.format_exc())
        return False 