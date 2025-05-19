import os
from dotenv import load_dotenv

# Load environment variables from .env file if it exists
load_dotenv()

# SQL Server Database configuration
DB_SERVER = os.getenv('DB_SERVER', 'DESKTOP-7PBR2IN')
DB_USER = os.getenv('DB_USER', 'DESKTOP-7PBR2IN\\user')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')
DB_NAME = os.getenv('DB_NAME', 'inventory_management')
DB_DRIVER = os.getenv('DB_DRIVER', 'SQL Server')
DB_TRUSTED_CONNECTION = os.getenv('DB_TRUSTED_CONNECTION', 'yes') == 'yes'

# API configuration
API_PREFIX = '/api'
PORT = int(os.getenv('PORT', '5001'))
DEBUG = os.getenv('DEBUG', 'True') == 'True'

# Business logic configuration
DEFAULT_PRICE_MARKUP = float(os.getenv('DEFAULT_PRICE_MARKUP', '1.3')) # 30% markup by default