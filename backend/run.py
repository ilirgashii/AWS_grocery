from app import create_app
from config import Config
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = create_app()

if __name__ == '__main__':
    logger.info(f"Starting server on port {Config.PORT}")
    logger.info(f"Static folder path: {app.static_folder}")
    app.run(host='0.0.0.0', port=Config.PORT, debug=True)
