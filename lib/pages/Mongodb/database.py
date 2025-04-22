from pymongo import MongoClient
from dotenv import load_dotenv
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    logger.error("MONGO_URI not set in .env file")
    raise ValueError("MONGO_URI not set in .env file")

try:
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    client.admin.command("ping")
    logger.info(f"Connected to MongoDB Atlas with URI: {MONGO_URI[:50]}... (redacted)")
    db = client["reneuw_db_bigdata"]
    user_collection = db["users1"]
    collections = db.list_collection_names()
    logger.info(f"Database: reneuw_db, collections: {collections}")
except Exception as e:
    logger.error(f"Failed to connect to MongoDB Atlas: {str(e)}", exc_info=True)
    raise Exception(f"Failed to connect to MongoDB Atlas: {str(e)}")



# db = client["reneuw_db"]
# user_collection = db["users"]
db = client["reneuw_db_bigdata"]
user_collection = db["users1"]
food_collection = db["food_entries"]