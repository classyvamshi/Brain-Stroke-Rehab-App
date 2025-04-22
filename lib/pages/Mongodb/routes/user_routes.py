from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import user_collection, food_collection
import logging
from datetime import datetime
from bson import ObjectId
from pymongo.errors import PyMongoError
import time

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

router = APIRouter()

class BodyMeasurement(BaseModel):
    gender: str | None = None
    height: float | None = None
    weight: float | None = None
    age: int | None = None
    goal: str | None = None
    activity_level: str | None = None
    bmi: float | None = None
    last_measured: str | None = None

class WaterData(BaseModel):
    water_consumed: float
    last_seen: str
    last_reset_date: str
    water_target: float

class UserBodyData(BaseModel):
    uid: str
    body_measurement: BodyMeasurement | None = None
    water_data: WaterData | None = None
    meal_targets: dict | None = None
    diet_tracking: dict | None = None
    nutrient_targets: dict | None = None

class FoodEntry(BaseModel):
    uid: str
    name: str
    calories: float
    carbs: float
    protein: float
    fat: float
    meal_type: str
    date: str

@router.post("/user")
async def save_user(data: UserBodyData):
    logger.info(f"POST /api/user received data: {data.dict(exclude_unset=True)}")
    try:
        user_data = data.dict(exclude_unset=True)
        current_date = datetime.utcnow().strftime("%Y-%m-%d")
        current_time = datetime.utcnow().strftime("%H:%M:%S")

        # Initialize update dictionary
        update_data = {
            "uid": data.uid,
            "updated_at": current_date
        }

        # Handle water_data explicitly
        if "water_data" in user_data and user_data["water_data"] is not None:
            water_data = user_data["water_data"]
            logger.info(f"Raw water_data received: {water_data}")
            # Validate water_data fields
            if not isinstance(water_data.get("water_consumed"), (int, float)):
                logger.warning(f"Invalid water_consumed type: {water_data['water_consumed']}, skipping update")
                raise HTTPException(status_code=400, detail="Invalid water_consumed value")
            if water_data["water_consumed"] < 0:
                logger.warning(f"Negative water_consumed: {water_data['water_consumed']}, skipping update")
                raise HTTPException(status_code=400, detail="Water consumed cannot be negative")
            if not water_data.get("last_seen"):
                water_data["last_seen"] = current_time
            if not water_data.get("last_reset_date"):
                water_data["last_reset_date"] = current_date
            if not isinstance(water_data.get("water_target"), (int, float)) or water_data["water_target"] <= 0:
                water_data["water_target"] = 2000.0

            # Update nested fields explicitly
            update_data["water_data.water_consumed"] = float(water_data["water_consumed"])
            update_data["water_data.last_seen"] = water_data["last_seen"]
            update_data["water_data.last_reset_date"] = water_data["last_reset_date"]
            update_data["water_data.water_target"] = float(water_data["water_target"])
        else:
            logger.warning(f"No water_data provided for uid {data.uid}, setting defaults")
            update_data["water_data.water_consumed"] = 0.0
            update_data["water_data.last_seen"] = current_time
            update_data["water_data.last_reset_date"] = current_date
            update_data["water_data.water_target"] = 2000.0

        # Handle other fields
        if "body_measurement" in user_data and user_data["body_measurement"] is not None:
            update_data["body_measurement"] = {
                k: v for k, v in user_data["body_measurement"].items() if v is not None
            }
        if "meal_targets" in user_data:
            update_data["meal_targets"] = user_data["meal_targets"]
        if "nutrient_targets" in user_data:
            update_data["nutrient_targets"] = user_data["nutrient_targets"]
        if "diet_tracking" in user_data:
            update_data["diet_tracking"] = user_data["diet_tracking"]

        # Perform update
        logger.info(f"Executing update_one with query: {{'uid': {data.uid}}}, update: {{$set: {update_data}}}")
        result = user_collection.update_one(
            {"uid": data.uid},
            {"$set": update_data},
            upsert=True
        )
        logger.info(f"Update result: matched={result.matched_count}, modified={result.modified_count}, upserted={result.upserted_id}, water_data={update_data.get('water_data.water_consumed', 'N/A')}")

        # Wait briefly to ensure write commit
        time.sleep(0.1)
        # Verify the document
        saved_doc = user_collection.find_one({"uid": data.uid}, {"_id": 0, "water_data": 1})
        logger.info(f"Verified document for uid {data.uid}: {saved_doc}")

        return {"status": "success", "message": "User data saved"}
    except PyMongoError as e:
        logger.error(f"MongoDB error saving user data for uid {data.uid}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"MongoDB error: {str(e)}")
    except Exception as e:
        logger.error(f"Error saving user data for uid {data.uid}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error saving user data: {str(e)}")

@router.get("/user/{uid}")
async def get_user(uid: str):
    logger.info(f"GET /api/user/{uid} requested")
    try:
        user = user_collection.find_one({"uid": uid}, {"_id": 0})
        current_date = datetime.utcnow().strftime("%Y-%m-%d")
        current_time = datetime.utcnow().strftime("%H:%M:%S")
        
        if user:
            # Ensure water_data exists
            if "water_data" not in user or not user["water_data"]:
                user["water_data"] = {
                    "water_consumed": 0.0,
                    "last_seen": current_time,
                    "last_reset_date": current_date,
                    "water_target": 2000.0
                }
                user_collection.update_one(
                    {"uid": uid},
                    {"$set": {"water_data": user["water_data"], "updated_at": current_date}}
                )
            logger.info(f"Found user for uid {uid}: water_data={user['water_data']}")
            return user
        
        # Create new user if not found
        default_user = {
            "uid": uid,
            "water_data": {
                "water_consumed": 0.0,
                "last_seen": current_time,
                "last_reset_date": current_date,
                "water_target": 2000.0
            },
            "meal_targets": {
                "breakfast_calories_target": 0.0,
                "lunch_calories_target": 0.0,
                "snack_calories_target": 0.0,
                "dinner_calories_target": 0.0
            },
            "nutrient_targets": {
                "carbs": 0.0,
                "protein": 0.0,
                "fat": 0.0
            },
            "updated_at": current_date
        }
        user_collection.insert_one(default_user)
        logger.info(f"Created new user for uid {uid}: water_data={default_user['water_data']}")
        return default_user
    except Exception as e:
        logger.error(f"Error retrieving user for uid {uid}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error retrieving user: {str(e)}")

@router.post("/food")
async def save_food_entry(food: FoodEntry):
    logger.info(f"POST /api/food received data: {food.dict()}")
    try:
        food_data = food.dict()
        food_data["created_at"] = datetime.utcnow().strftime("%Y-%m-%d %H:%M:S")
        result = food_collection.insert_one(food_data)
        logger.info(f"Food entry saved with id: {result.inserted_id}")
        return {"status": "success", "message": "Food entry saved", "id": str(result.inserted_id)}
    except Exception as e:
        logger.error(f"Error saving food entry: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error saving food entry: {str(e)}")

@router.get("/food")
async def get_food_entries(date: str, uid: str):
    logger.info(f"GET /api/food requested for date {date} and uid {uid}")
    try:
        entries = list(food_collection.find({"date": date, "uid": uid}, {"_id": 1, "name": 1, "calories": 1, "carbs": 1, "protein": 1, "fat": 1, "meal_type": 1}))
        for entry in entries:
            entry["_id"] = str(entry["_id"])
        logger.info(f"Found {len(entries)} food entries")
        return entries
    except Exception as e:
        logger.error(f"Error retrieving food entries: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error retrieving food entries: {str(e)}")

@router.delete("/food/delete/{entry_id}")
async def delete_food_entry(entry_id: str):
    logger.info(f"DELETE /api/food/delete/{entry_id} requested")
    try:
        result = food_collection.delete_one({"_id": ObjectId(entry_id)})
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Food entry not found")
        logger.info(f"Food entry {entry_id} deleted")
        return {"status": "success", "message": "Food entry deleted"}
    except Exception as e:
        logger.error(f"Error deleting food entry {entry_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error deleting food entry: {str(e)}")

@router.get("/nutrition")
async def get_nutrition_data(food: str):
    logger.info(f"GET /api/nutrition requested for food: {food}")
    try:
        # Mock nutrition data (replace with actual API call if available)
        nutrition_data = {
            "calories": 100.0,
            "carbs": 20.0,
            "protein": 5.0,
            "fat": 2.0
        }
        return nutrition_data
    except Exception as e:
        logger.error(f"Error fetching nutrition data for {food}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error fetching nutrition data: {str(e)}")